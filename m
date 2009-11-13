From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 09:26:18 +0800
Message-ID: <412e6f7f0911121726t47874807g2223d2f1141818f5@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com>
	 <4AFC0436.9090906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:61088 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642AbZKMB0M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 20:26:12 -0500
Received: by pzk1 with SMTP id 1so950812pzk.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 17:26:18 -0800 (PST)
In-Reply-To: <4AFC0436.9090906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/12 Eric Dumazet <eric.dumazet@gmail.com>:
>
> I believe this patch is fine, but maybe Jarek concern about workqueue
> vs tasklet should be addressed...
>
> We could use the previous handling in case numtxqs=3D=3D1 , ie use a =
tasklet
> instead of a work queue ?

I don't think it is a good idea. If we do so, the code will be messy,
and lost the flexibility of process. In fact, latency isn't a problem
when system load isn't high, and when system load is high (due to too
many NIC IRQs), throughput and interaction is more important, and the
current linux networking subsystem just dose so through the softirqd
mechanism.

>
>
> Sorry for this late idea...
>



--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)
