From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Tue, 09 Oct 2012 08:07:43 +0200
Message-ID: <1349762863.21172.3848.camel@edumazet-glaptop>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
	 <1339030752.2075.1.camel@jtkirshe-mobl>
	 <1339043085.26966.77.camel@edumazet-glaptop>
	 <1339044752.2075.14.camel@jtkirshe-mobl>
	 <loom.20121009T020718-563@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Frank Reppin <frank@undermydesk.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35986 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030Ab2JIGHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 02:07:46 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2393149bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 23:07:45 -0700 (PDT)
In-Reply-To: <loom.20121009T020718-563@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 00:25 +0000, Frank Reppin wrote:
> Jeff Kirsher <jeffrey.t.kirsher <at> intel.com> writes:
> > 
> > On Thu, 2012-06-07 at 06:24 +0200, Eric Dumazet wrote:
> > > On Wed, 2012-06-06 at 17:59 -0700, Jeff Kirsher wrote:
> > > 
> > > > After further internal review, NACK.
> > > > 
> > > > This patch will cause unacceptable performance issues with non-ESB2
> > > > parts.
> > > > 
> > > > I am dropping this patch from my queue.
> > > > 
> > > 
> > > I'd like you share your performance numbers before NACKing this patch.
> > > 
> > > What is the alternative patch you guys have ?
> > > 
> > 
> > Jesse did not share any performance numbers with me, I am sure he can
> > give some background tomorrow when he is back online.
> > 
> > I am working on an alternative patch now and should have something to
> > share tomorrow.
> Please allow me to ask if there's any progess here?
> 
> I've tried 3.5.4 a couple of days ago on a SuperMicro X8SIE-LN4 (82574L)
> and could still observe severe latency (up to 3000ms) spikes.
> 
> Applying Hiroakis suggested patch did fix this for me as well.
> [please note as well that I didn't had this issue in any 3.4.x kernel
> before - so +1 for fixing the regression]

Its a shame this bug is not yet fixed.

I dont know what to say.
