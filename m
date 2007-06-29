From: jamal <hadi@cyberus.ca>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 09:19:52 -0400
Message-ID: <1183123192.5188.43.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>
	 <46840AF5.4020209@trash.net>
	 <20070628.212032.108743475.davem@davemloft.net>
	 <1183117415.5156.61.camel@localhost>  <4684F41B.9080309@trash.net>
	 <1183121670.5188.16.camel@localhost>  <46850450.6040608@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:53403 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbXF2NT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 09:19:56 -0400
Received: by wr-out-0506.google.com with SMTP id q50so485578wrq
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 06:19:55 -0700 (PDT)
In-Reply-To: <46850450.6040608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-29-06 at 15:08 +0200, Patrick McHardy wrote:
> jamal wrote:
> > On Fri, 2007-29-06 at 13:59 +0200, Patrick McHardy wrote:

> Right, but the current bridging code always uses promiscous mode
> and its nice to avoid that if possible. 
> Looking at the code, it
> should be easy to avoid though by disabling learning (and thus
> promisous mode) and adding unicast filters for all static fdb entries.
> 

Yes, that would do it for static provisioning (I suspect that would work
today unless bridging has no knobs to turn off going into promisc). But
you could even allow for learning and just have extra filters in tc
before bridging disallowing things.

> Have a look at my secondary unicast address patches in case you didn't
> notice them before (there's also a driver example for e1000 on netdev):
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.23.git;a=commit;h=306890b54dcbd168cdeea64f1630d2024febb5c7
> 
> You still need to do filtering in software, but you can have the NIC
> pre-filter in case it supports it, otherwise it goes to promiscous mode.
> 

Ok, I will look at them when i get back. Sorry - havent caught up on
netdev.

cheers,
jamal

