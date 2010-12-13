From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-2.6 1/3] bonding/vlan: Remove redundant VLAN tag
 insertion logic
Date: Mon, 13 Dec 2010 14:08:02 -0800
Message-ID: <AANLkTi=BmmTzK29pQWLhGtROGA+OX72170zN_7VwdrM6@mail.gmail.com>
References: <1292264216.9860.11.camel@bwh-desktop>
	<1292264368.9860.13.camel@bwh-desktop>
	<30647.1292270297@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:48825 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758042Ab0LMWID convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 17:08:03 -0500
Received: by fxm18 with SMTP id 18so6855063fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:08:02 -0800 (PST)
In-Reply-To: <30647.1292270297@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 11:58 AM, Jay Vosburgh <fubar@us.ibm.com> wrote=
:
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>
>>A bond may have a mixture of slave devices with and without hardware
>>VLAN tag insertion capability. =A0Therefore it always claims this
>>capability and performs software VLAN tag insertion if the slave does
>>not.
>>
>>Since commit 7b9c60903714bf0a19d746b228864bad3497284e, this has
>>also been done by dev_hard_start_xmit(). =A0The result is that VLAN-
>>tagged skbs are now double-tagged when transmitted through slave
>>devices without hardware VLAN tag insertion!
>>
>>Remove the now-redundant logic from bond_dev_queue_xmit().
>>
>>Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Thanks for catching this.  I had this change but it was grouped in
with some other bonding/vlan simplifications that were dependent on
the rest of the drivers being converted.

Reviewed-by: Jesse Gross <jesse@nicira.com>
