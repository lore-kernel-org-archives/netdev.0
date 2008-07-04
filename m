From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] support for IEEE 1588
Date: Fri, 4 Jul 2008 03:42:36 +0300
Message-ID: <200807040342.36505.opurdila@ixiacom.com>
References: <200807040147.11148.opurdila@ixiacom.com> <200807040240.04801.opurdila@ixiacom.com> <486D6B87.9030409@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1504 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754061AbYGDAoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 20:44:38 -0400
In-Reply-To: <486D6B87.9030409@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 July 2008, Rick Jones wrote:

> I've not had a good emily litella moment in at least a week, so I'll ask
> - if the clock in the hardware generating the timestamp and the clock in
> the host aren't synchronized in _some_ way, what benefit is there to
> putting the hardware's timestamp in there?
>

We actually currently use them for delay/jitter calculation in conjunction 
with having the RX and TX port's source timestamping units running in sync. 
We can do that since both the RX and TX port (Linux based) will run in our 
hardware (chassis).

I guess we could try to do a simple sync between the host clock and the hw 
clock by getting the initial delta between the two. But since the two clocks 
are not in sync, they will diverge in time. And since I do not know enough 
about the way in which tstamp is currently used, I'm not very confident that 
this will not break something... so, back to grepping :)

Thanks,
tavi


