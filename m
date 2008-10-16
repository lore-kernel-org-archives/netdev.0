From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Thu, 16 Oct 2008 13:08:51 +0000
Message-ID: <20081016130851.GC20302@ff.dom.local>
References: <20081016094645.GA19019@ff.dom.local> <48F735C7.6050808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:2922 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbYJPNI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 09:08:58 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1688113ugf.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 06:08:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F735C7.6050808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2008 at 02:38:31PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> So here is my try (I hope I didn't miss Patrick's intentions to much).
>>
>> PATCH 6/6 adds my simple idea not to prevent even nonsense configs.
>> It is optional.
>
> These patches look good to me. About 6/6, I'm still thinking we
> might want to prevent certain kinds of nonsensical configurations
> for simplicity. Its a bit similar to the multiq stuff, a lot of
> these complications came from the fact that non-work-conserving
> qdiscs, which require a global view, are treated similar to work-
> conserving ones. I don't have a good scheme worked out though,
> so for now using your patch seems OK too.
>
>> PS: after this patchset only netem_enqueue() needs qdisc->requeue(),
>> but I hope this won't take too long.
>
> Assuming work-conserving qdiscs are used with netem, the currently
> code will always send out a reorder packet immediately. This behaviour
> is trivial to implement without ->requeue. The problematic case is
> non-work-conserving inner qdiscs, but that doesn't seem important
> at all since you'd usually add it as parent of netem, which still
> works.

Patrick, thanks for the feedback so far. I have to have some break now
so I'll try to respond or redo this, if needed, in the evening.

Jarek P.
