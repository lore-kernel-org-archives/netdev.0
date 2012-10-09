From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Tue, 9 Oct 2012 10:36:29 -0700
Message-ID: <20121009103629.0000569a@unknown>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
	<1339030752.2075.1.camel@jtkirshe-mobl>
	<1339043085.26966.77.camel@edumazet-glaptop>
	<1339044752.2075.14.camel@jtkirshe-mobl>
	<loom.20121009T020718-563@post.gmane.org>
	<1349762863.21172.3848.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Frank Reppin <frank@undermydesk.org>, <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2933 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754998Ab2JIRgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 13:36:45 -0400
In-Reply-To: <1349762863.21172.3848.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > Jesse did not share any performance numbers with me, I am sure he can
> > > give some background tomorrow when he is back online.
> > > 
> > > I am working on an alternative patch now and should have something to
> > > share tomorrow.
> > Please allow me to ask if there's any progess here?
> > 
> > I've tried 3.5.4 a couple of days ago on a SuperMicro X8SIE-LN4 (82574L)
> > and could still observe severe latency (up to 3000ms) spikes.
> > 
> > Applying Hiroakis suggested patch did fix this for me as well.
> > [please note as well that I didn't had this issue in any 3.4.x kernel
> > before - so +1 for fixing the regression]

I'm not sure what went wrong internally here that this hasn't been
fixed, and I'm personally embarrassed.  I am working on it until I have
a patch/solution.

currently am trying to reproduce the issue, am in some weird how to
use BQL limbo, the lack of documentation on user usage of BQL is slowing
me down.

Hints or clues (I'm trying to follow the repro steps mentioned in
some related threads) are appreciated.
