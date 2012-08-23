From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to
 stalled CPU task )
Date: Thu, 23 Aug 2012 07:57:12 +0000 (UTC)
Message-ID: <k14noo$lfj$1@ger.gmane.org>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
 <1345634026.5158.1084.camel@edumazet-glaptop>
 <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
 <1345640757.5158.1321.camel@edumazet-glaptop>
 <CAF6-1L7nRoG10P=+QRb=LfL4O8K877zUD6L6d5EoCq-QNt1FWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48125 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932160Ab2HWH5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 03:57:34 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1T4SIA-0004ji-FO
	for netdev@vger.kernel.org; Thu, 23 Aug 2012 09:57:26 +0200
Received: from 112.132.201.16 ([112.132.201.16])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 09:57:26 +0200
Received: from xiyou.wangcong by 112.132.201.16 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 09:57:26 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Aug 2012 at 14:29 GMT, Sylvain Munaut <s.munaut@whatever-company.com> wrote:
> Hi,
>
>
> The machine with the intel card still hard freeze (no output / no nothing ...)
> The machine with the bnx2 don't crash anymore and no NULL deref, but
> the modprobe still hangs and I get this every 180 sec or so :

The NULL-deref can be reproduced easily, and Eric's patch could fix it.
So, Eric, can you resend your patch with your SOB?

I can't reproduce the hang as it is net driver specific, it is
probably related with my patch:

commit 6bdb7fe31046ac50b47e83c35cd6c6b6160a475d
Author: Amerigo Wang <amwang@redhat.com>
Date:   Fri Aug 10 01:24:50 2012 +0000

    netpoll: re-enable irq in poll_napi()
