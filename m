From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 10:26:04 -0800
Message-ID: <4786633C.6000308@hp.com>
References: <1199981839.8931.35.camel@cafe>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:15951 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754671AbYAJS0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 13:26:07 -0500
In-Reply-To: <1199981839.8931.35.camel@cafe>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many many things to check when running netperf :)

*) Are the cards on the same or separate PCImumble bus, and what sort of bus

*) is the two interface performance two interfaces on the same four-port 
card, or an interface from each of the two four-port cards?

*) is there a dreaded (IMO) irqbalance daemon running?  one of the very 
first things I do when running netperf is terminate the irqbalance 
daemon with as extreme a predjudice as I can.

*) what is the distribution of interrupts from the interfaces to the 
CPUs?  if you've tried to set that manually, the dreaded irqbalance 
daemon will come along shortly thereafter and ruin everything.

*) what does netperf say about the overall CPU utilization of the 
system(s) when the tests are running?

*) what does top say about the utilization of any single CPU in the 
system(s) when the tests are running?

*) are you using the global -T option to spread the netperf/netserver 
processes across the CPUs, or leaving that all up to the 
stack/scheduler/etc?

I suspect there could be more but that is what comes to mind thusfar as 
far as things I often check when running netperf.

rick jones

