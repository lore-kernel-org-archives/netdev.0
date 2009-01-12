From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
 jiffies in htb_dequeue()
Date: Mon, 12 Jan 2009 14:10:53 +0100
Message-ID: <496B415D.8050401@trash.net>
References: <20081210093532.GA7926@ff.dom.local> <20081216.155722.144236025.davem@davemloft.net> <20081217070303.GA4577@ff.dom.local> <20081216.233801.26557633.davem@davemloft.net> <496AE9A5.9060507@trash.net> <20090112101047.GA5448@ff.dom.local> <496B19F7.4060909@trash.net> <20090112110857.GB5901@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64089 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbZALNKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 08:10:55 -0500
In-Reply-To: <20090112110857.GB5901@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Jan 12, 2009 at 11:22:47AM +0100, Patrick McHardy wrote:
> ...
>> It doesn't bother me :) I just think its the technical better
>> and also most likely code-wise cleaner solution to this problem.
>> Cancellation wouldn't be necessary since an unnecessary
>> netif_schedule() doesn't really matter.
> 
> Hmm... Do you mean during destroying... It's probably not very long,
> but deleting and creating qdiscs especially for some virtual devices
> can take longer I guess.

I was referring to your statement "but also some overhead when
cancelling this workqueue" and assumed you meant during packet
processing. In the destruction path it really doesn't matter at
all.
