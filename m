From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 00:19:13 +0200
Message-ID: <20080822221913.GA2981@ami.dom.local>
References: <1219415417.4672.79.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:16649 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753757AbYHVWSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 18:18:23 -0400
Received: by ug-out-1314.google.com with SMTP id c2so247800ugf.37
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 15:18:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1219415417.4672.79.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote, On 08/22/2008 04:30 PM:
...
> There are two issues at stake:
> 1) egress Multiq support and the desire to have concurency based on
> however many cpus and hardware queues exist on the system.
> 2) scheduling of the such hardware queues being executed by the hardware
> (and not by software).
> 
> Daves goal: #1; run faster than Usain Bolt.

Looks fine.

> What we were solving at the time: #2. My view was to solve it with
> minimal changes.
> 
> #1 and #2 are orthogonal. Yes, there is religion: Dave yours is #1.
> Intels is #2; And there are a lot of people in intels camp because
> they bill their customers based on qos of resources. The wire being one
> such resource.

If we can guarentee that current, automatic steering gives always the
best performance than David seems to be right. But I doubt it, and
that's why I think such a simple, manual control could be useful.
Especially if it doesn't add much overhead.

> Therefore your statement that these schemes exist to "enforce fairness
> amongst the TX queues" needs to be qualified mon ami;-> The end parts of
> Animal Farm come to mind: Some animals have more rights than others;->

Sure, but shouldn't this other kind of fairness be applied on lower
levels?

Cheers,
Jarek P.
