From: jamal <hadi@cyberus.ca>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Tue, 03 Jul 2007 22:20:11 -0400
Message-ID: <1183515611.5174.34.camel@localhost>
References: <1183215164.5165.13.camel@localhost>
	 <20070630.133357.77057070.davem@davemloft.net>
	 <1183466553.5159.51.camel@localhost>
	 <20070703.142431.49854676.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:37136 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbXGDCUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 22:20:16 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1962053wxd
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 19:20:16 -0700 (PDT)
In-Reply-To: <20070703.142431.49854676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-03-07 at 14:24 -0700, David Miller wrote:
[.. some useful stuff here deleted ..]

> That's why you have to copy into a purpose-built set of memory
> that is composed of pages that _ONLY_ contain TX packet buffers
> and nothing else.
> 
> The cost of going through the switch is too high, and the copies are
> necessary, so concentrate on allowing me to map the guest ports to the
> egress queues.  Anything else is a waste of discussion time, I've been
> pouring over these issues endlessly for weeks, so if I'm saying doing
> copies and avoiding the switch is necessary I do in fact mean it. :-)

ok, i get it Dave ;-> Thanks for your patience, that was useful.
Now that is clear for me, I will go back and look at your original email
and try to get back on track to what you really asked ;->

cheers,
jamal

