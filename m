From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv3] Add missing memory barriers to clean_rx_irq functions
	in Intel Drivers
Date: Tue, 27 Jul 2010 16:08:19 -0700
Message-ID: <AANLkTim5WdY6GVNXV1ZRVhF0AvSmZwoySg+CPx7sL4s7@mail.gmail.com>
References: <20100727223452.GM17248@us.ibm.com>
	<20100727224434.GN17248@us.ibm.com>
	<AANLkTikMNFSyPxRCXc=cPWHkOfsx9iH0mEu-TH7bHL_h@mail.gmail.com>
	<20100727230540.GQ17248@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
To: Sonny Rao <sonnyrao@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57976 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab0G0XIU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 19:08:20 -0400
Received: by iwn7 with SMTP id 7so4132906iwn.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 16:08:19 -0700 (PDT)
In-Reply-To: <20100727230540.GQ17248@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 16:05, Sonny Rao <sonnyrao@us.ibm.com> wrote:
> On Tue, Jul 27, 2010 at 03:45:42PM -0700, Jeff Kirsher wrote:
>>
>> You also seem to be missing igb.
>
> This patch is similar to what was fixed in ixgbe in this patch:
>
> http://marc.info/?l=3De1000-devel&m=3D126593062701537&w=3D3
>
> We should add read memory barriers to all the similar cases across th=
e
> Intel ethernet driver family. =C2=A0In the case of ixgbevf, igb, and =
igbvf
> I've also added a missing barrier to the clean_tx_irq path because I
> missed it in my last patch.
>
> Without the barrier a processor can speculate a load ahead of the loa=
d
> which looks at the status bit and get stale information causing a
> number of different issues including invalid packet length, NULL
> pointers, or bad data since checksumming was assumed to be done
> in hardware.
>
> v2: I missed the e100 the first time
> v3: I missed igb and igbvf, third time's the charm?
>
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Sonny Rao <sonnyrao@us.ibm.com>
> cc: stable <stable@kernel.org>
>

Thanks, I have added the patch to my queue.

--=20
Cheers,
Jeff
