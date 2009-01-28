From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
 jiffies in htb_dequeue()
Date: Wed, 28 Jan 2009 17:20:36 +0100
Message-ID: <498085D4.1010406@trash.net>
References: <20090128132353.GA6443@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34788 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbZA1QUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 11:20:38 -0500
In-Reply-To: <20090128132353.GA6443@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 12-01-2009 11:22, Patrick McHardy wrote:
>> It you don't mind adding the workqueue, I certainly would prefer
>> it, but I'm also fine with this patch. I don't have a HTB setup
>> or a testcase for this specific case, otherwise I'd simply do it
>> myself.
> 
> Here is an example of this workqueue. I hope I didn't miss your point,
> but since I didn't find much difference in testing, I'd prefer not to
> sign-off/merge this yet, at least until there are many reports on
> "too many events" problem, and somebody finds it useful.

No, this seems to be exactly what I meant. The differnce - yeah, it
shouldn't make much, mainly wake up the qdisc earlier (but not too
early) after "too many events" occured _and_ no further enqueue
events wake up the qdisc anyways.
