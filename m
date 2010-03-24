From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase enqueue/dequeue fairness
Date: Wed, 24 Mar 2010 03:12:12 +0100
Message-ID: <87634mh3ib.fsf@basil.nowhere.org>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	<20100323.133124.139557595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:42355 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab0CXCMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 22:12:19 -0400
In-Reply-To: <20100323.133124.139557595.davem@davemloft.net> (David Miller's message of "Tue, 23 Mar 2010 13:31:24 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Tue, 23 Mar 2010 13:25:53 -0700
>
>> The qdisc layer shows a significant issue when you start transmitting from
>> multiple CPUs.
>
> Why are you hitting any central qdisc lock on a multiqueue
> configuration?

One thing to remember is that systems can have a lot more CPUs than a NIC queues
(e.g. 64 vs 8)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
