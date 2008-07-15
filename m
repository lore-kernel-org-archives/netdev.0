From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH net-next-2.6 v4 2/2] hfsc: add link layer overhead
	adaption
Date: Tue, 15 Jul 2008 13:52:44 +0300
Message-ID: <20080715135244.17106mgc64fxlpj4@hayate.ip6>
References: <20080710193434.19525.83454.stgit@fate.lan>
	<20080710193440.19525.93085.stgit@fate.lan> <487B61A9.5090204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:38977 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbYGOKwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 06:52:47 -0400
In-Reply-To: <487B61A9.5090204@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Patrick McHardy" <kaber@trash.net>:

>
> I thought you were going to make this a generic qdisc feature.
> Why is configuration still qdisc specific?
>

I was thinking keeping scope of this patch within hfsc, as done with  
rest of rate table qdiscs. So it would be better to have they all to  
use generic size table instead of duplicating rtab code.

> I was thinking of something like this:
>
> - add generic attributes for configuring size tables for any
>   qdisc, handle those in sch_api
>
> - add qdisc_enqueue() wrapper that calculates the size and
>   stores it in skb->cb, convert direct calls of sch->enqueue
>   to use it
>
> - change direct uses of skb->len to use the size from the cb
>
> The second step might need a bit more thought to make sure
> qdiscs don't get confused when the dequeued packet is larger
> than the enqueued one, but I think they usually don't care.
>

I guess I'll start over using your size table patch as base then.

  - Jussi



