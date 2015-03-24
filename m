From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Intialize link state to down before
 register_netdev
Date: Mon, 23 Mar 2015 21:41:58 -0400 (EDT)
Message-ID: <20150323.214158.443787308513621428.davem@davemloft.net>
References: <OF3CCCBC69.C8C0BA7E-ON88257E11.005C1D2B-88257E11.005C420A@selinc.com>
	<CADRPPNRaCf+TNwTvo_g+j7GhT9tO_H+z7Ury44-2MB4hoa2UFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cliff_clark@selinc.com, netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbbCXBmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 21:42:02 -0400
In-Reply-To: <CADRPPNRaCf+TNwTvo_g+j7GhT9tO_H+z7Ury44-2MB4hoa2UFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Mon, 23 Mar 2015 17:03:59 -0500

> On Mon, Mar 23, 2015 at 11:47 AM,  <cliff_clark@selinc.com> wrote:
>> ucc_geth was indicating link up after a port is administratively enabled
>> even
>> when nothing is plugged in.  This causes user-space tools to see a
>> spurious link
>> up the first time after boot.
>>
>> Signed-off-by: Cliff Clark <cliff_clark@selinc.com>
> 
> Ack for the change, but the commit message is having messy line breaks.

Yes, it's really ugly, please fix this.

Don't reply upon a graphical UI or whatever to format these commit
messages properly.  Use a plain ASCII text editor and get the column
breaks right.
