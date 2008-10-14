From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 12:26:50 +0000
Message-ID: <20081014122650.GA12373@ff.dom.local>
References: <20081014095246.GA10804@ff.dom.local> <48F484EB.8000201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:9881 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491AbYJNM1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 08:27:16 -0400
Received: by ug-out-1314.google.com with SMTP id k3so894738ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 05:26:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F484EB.8000201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 01:39:23PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> The aim of this patch-set is to finish changes proposed by David S.
>> Miller in his patch-set with the same subject from Mon, 18 Aug 2008.
>> The first two patches were applied with some modifications, so, to
>> apply the rest, there were needed some changes.
>>
>> Original David's patches include additional info, but signed-off-by
>> is removed because of changed context. I expect they will be merged
>> and signed off by David as an author, anyway.
>>
>> The qdisc->requeue list idea is to limit requeuing to one level only,
>> so a parent can requeue to its child only. This list is then tried
>> first while dequeuing (qdisc_dequeue()), except at the top level,
>> so packets could be requeued only by qdiscs, not by qdisc_restart()
>> after xmit errors.
>
> I didn't follow the original discussion, but I'm wondering what
> the reasoning is why these patches won't have negative impact
> on latency. Consider these two scenarios with HFSC or TBF:

Hmm... What a pity you couldn't write this a bit earlier, because I've
just waited with this part for some distinct cons of this solution.

Alas, I can't analyze your concerns at the moment, and I'll try to
reply in the evening yet, but my idea was this all shouldn't make
(almost) any visible change just for HFSC, so if it's otherwise,
something went wrong. IMHO, with this solution hfsc_requeue() way is
simply realized as a standard now, but I can miss something.

Thanks for now,
Jarek P.
