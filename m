From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 14:16:40 +0800
Message-ID: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com>
	 <4AFC0436.9090906@gmail.com>
	 <412e6f7f0911121726t47874807g2223d2f1141818f5@mail.gmail.com>
	 <4AFCF50D.6040106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:57553 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbZKMGQf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 01:16:35 -0500
Received: by pzk1 with SMTP id 1so1085158pzk.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 22:16:41 -0800 (PST)
In-Reply-To: <4AFCF50D.6040106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/13 Eric Dumazet <eric.dumazet@gmail.com>:
>
> Messy ? Because of few tests added in code, and branches always
> correctly predicted ?
>
> Still some people might rely on tasklet instead of workqueues
> and added scheduler stress and latency penalty. Tasklet are softirq
> and normally are processed a few nanosecs later than RX softirq,
> on the same CPU, while with your workqueue, I guess the scheduler wil=
l
> try to not migrate it, so we add a penalty for light to moderate load=
=2E
>
> I guess this new ifb mode would be a regression for them ?
>
> If you dont want to maintain a compatibility mode, maybe you
> should introduce a complete new driver, drivers/net/ifbmq.c or ifbwq.=
c
>
> (multiqueue or workqueue references)
>

It sounds a good idea.

--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)
