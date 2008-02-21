From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sungem triggers NAPI warning
Date: Fri, 22 Feb 2008 09:50:27 +1100
Message-ID: <1203634227.10422.200.camel@pasglop>
References: <1203457124.3874.2.camel@johannes.berg>
	 <1203562472.10422.102.camel@pasglop>
	 <1203599125.4427.0.camel@johannes.berg>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55559 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbYBUWuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 17:50:54 -0500
In-Reply-To: <1203599125.4427.0.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-02-21 at 14:05 +0100, Johannes Berg wrote:
> On Thu, 2008-02-21 at 13:54 +1100, Benjamin Herrenschmidt wrote:
> > On Tue, 2008-02-19 at 22:38 +0100, Johannes Berg wrote:
> > > I started getting this warning with recent kernels:
> > 
> > Do that help ?
> > 
> > In gem_poll(), do:
> > 
> > -  work_done += gem_rx(gp, budget);
> > +  work_done += gem_rx(gp, budget - work_done);
> 
> That looks correct, but I haven't been able to trigger the warning again
> even with similar workloads so I haven't tested this change because I
> can't even reproduce without it.

I still think the change is obviously correct, so I'll give a second
close look at the code and produce a patch.

Ben.


