From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Wed, 30 Dec 2015 14:30:35 -0800
Message-ID: <CAM_iQpVQNPQ1LNvG+h3=UvTM9Lm-adhryQk-ad4aeckHS-V0ew@mail.gmail.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	<87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	<20151229.150843.2021692616139434395.davem@davemloft.net>
	<CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
	<CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
	<CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 6:30 AM, Jacob Siverskog
<jacob@teenage.engineering> wrote:
> On Wed, Dec 30, 2015 at 2:26 PM, Eric Dumazet <edumazet@google.com> wrote:
>> How often can you trigger this bug ?
>
> Ok. I don't have a good repro to trigger it unfortunately, I've seen it just a
> few times when bringing up/down network interfaces. Does the trace
> give any clue?
>

A little bit. You need to help people to narrow down the problem
because there are too many places using skb->next and skb->prev.

Since you mentioned it seems related to network interface flip,
what network interfaces are you using? What's is your TC setup?

Thanks.
