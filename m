From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
 jiffies in htb_dequeue()
Date: Mon, 12 Jan 2009 07:56:37 +0100
Message-ID: <496AE9A5.9060507@trash.net>
References: <20081210093532.GA7926@ff.dom.local>	<20081216.155722.144236025.davem@davemloft.net>	<20081217070303.GA4577@ff.dom.local> <20081216.233801.26557633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, devik@cdi.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57165 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbZALG4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 01:56:39 -0500
In-Reply-To: <20081216.233801.26557633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 17 Dec 2008 07:03:03 +0000
> 
>> On Tue, Dec 16, 2008 at 03:57:22PM -0800, David Miller wrote:
>>> Patrick, I know you said you were travelling and very busy,
>>> but Jarek has been waiting patiently for you to review
>>> these two newly respun patches.
>>>
>>> These are just rotting in my patch queue and I'd like to
>>> do something with them.
>> I guess Patrick has some doubts, but since these patches are not
>> critical, let's say I'll resend them within a few weeks.
> 
> Fair enough, I'll mark them deferred on patchwork

Sorry, I dropped the ball on this one. I still think scheduling
a work-queue or something else running in process context to
kick the queue once the scheduler had a chance to run would
be a better solution. But Jarek's patches are an improvement
to the current situation, so no objections from me.


