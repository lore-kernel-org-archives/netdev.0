From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Wed, 11 Nov 2009 18:57:08 +0800
Message-ID: <412e6f7f0911110257s2bbca7aei648e324832ae455d@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFA9235.1030004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f177.google.com ([209.85.216.177]:53757 "EHLO
	mail-px0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417AbZKKK5D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 05:57:03 -0500
Received: by pxi7 with SMTP id 7so700812pxi.17
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 02:57:08 -0800 (PST)
In-Reply-To: <4AFA9235.1030004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/11 Eric Dumazet <eric.dumazet@gmail.com>:
>
> Or even better, tq could be local to ifb_xmit()
>
> ifb_xmit() would purge it itself, and could use __skb_dequeue() and
> other lockless primitives.
>
> The whole :
>
> while ((skb =3D skb_dequeue(&pq->rq)) !=3D NULL)
>        skb_queue_tail(&pq->tq, skb);
>
> could be optimized a lot IMHO, its almost a skb_queue_splice() thing.=
=2E.
>

Thanks, it is a good idea. Any others?


--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)
