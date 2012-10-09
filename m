From: Frank Reppin <frank@undermydesk.org>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx stalls.
Date: Tue, 9 Oct 2012 00:25:35 +0000 (UTC)
Message-ID: <loom.20121009T020718-563@post.gmane.org>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>  <1339030752.2075.1.camel@jtkirshe-mobl>  <1339043085.26966.77.camel@edumazet-glaptop> <1339044752.2075.14.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40061 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab2JIAaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 20:30:01 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TLNhz-0004V9-VI
	for netdev@vger.kernel.org; Tue, 09 Oct 2012 02:30:04 +0200
Received: from p57AE7DD2.dip.t-dialin.net ([87.174.125.210])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 02:30:03 +0200
Received: from frank by p57AE7DD2.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 02:30:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher <at> intel.com> writes:
> 
> On Thu, 2012-06-07 at 06:24 +0200, Eric Dumazet wrote:
> > On Wed, 2012-06-06 at 17:59 -0700, Jeff Kirsher wrote:
> > 
> > > After further internal review, NACK.
> > > 
> > > This patch will cause unacceptable performance issues with non-ESB2
> > > parts.
> > > 
> > > I am dropping this patch from my queue.
> > > 
> > 
> > I'd like you share your performance numbers before NACKing this patch.
> > 
> > What is the alternative patch you guys have ?
> > 
> 
> Jesse did not share any performance numbers with me, I am sure he can
> give some background tomorrow when he is back online.
> 
> I am working on an alternative patch now and should have something to
> share tomorrow.
Please allow me to ask if there's any progess here?

I've tried 3.5.4 a couple of days ago on a SuperMicro X8SIE-LN4 (82574L)
and could still observe severe latency (up to 3000ms) spikes.

Applying Hiroakis suggested patch did fix this for me as well.
[please note as well that I didn't had this issue in any 3.4.x kernel
before - so +1 for fixing the regression]

Thankyou!
Frank Reppin

-- 
