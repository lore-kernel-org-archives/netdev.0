From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Add missing memory barriers to clean_rx_irq functions in
	Intel Drivers
Date: Tue, 27 Jul 2010 15:41:46 -0700
Message-ID: <AANLkTiniyOsNifzP47qR_zhq993U8p5wj1iJ+v4jzZkX@mail.gmail.com>
References: <20100727223452.GM17248@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
To: Sonny Rao <sonnyrao@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50185 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab0G0WmI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 18:42:08 -0400
Received: by iwn7 with SMTP id 7so4108002iwn.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 15:42:07 -0700 (PDT)
In-Reply-To: <20100727223452.GM17248@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 15:34, Sonny Rao <sonnyrao@us.ibm.com> wrote:
> This patch is similar to what was fixed in ixgbe in this patch:
>
> http://marc.info/?l=3De1000-devel&m=3D126593062701537&w=3D3
>
> We should add read memory barriers to all the similar cases across th=
e
> Intel ethernet driver family. =C2=A0In the case of ixgbevf I've also =
added
> a missing barrier to the clean_tx_irq path because I missed it in my
> last patch.
>
> Without the barrier a processor can speculate a load ahead of the loa=
d
> which looks at the status bit and get stale information causing a
> number of different issues including invalid packet length, NULL
> pointers, or bad data since checksumming was assumed to be done
> in hardware.
>
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Sonny Rao <sonnyrao@us.ibm.com>
> cc: stable <stable@kernel.org>
>

I already have a similar patch in my queue from you Sonny, although I
see that this patch has made a few more changes.  Is this version 2?

--=20
Cheers,
Jeff
