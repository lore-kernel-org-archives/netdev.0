From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Wed, 30 Oct 2013 15:01:12 -0700
Message-ID: <CAM_iQpWAbSWVeAMwhQADTwO_RdYUXfog-wG9gs4+Zek0g_5Oyg@mail.gmail.com>
References: <CAM_iQpXzJOxZ3MFNthKw5ye=WcxDWbiPaHuL=pHMz7D1R4nJ+w@mail.gmail.com>
	<20131030.024003.1476890051483056287.davem@davemloft.net>
	<CAM_iQpV6ufX5-OOrNQtsXH0_9itjU-FriOoutyKfDEWdg-irQw@mail.gmail.com>
	<20131030.173200.2256841895208134119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: TD Mackey <tdmackey@booleanhaiku.com>, mchan@broadcom.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131030.173200.2256841895208134119.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 30, 2013 at 2:32 PM, David Miller <davem@davemloft.net> wrote:
>
> Explain to me then why other ethernet drivers implemented identically,
> such as tg3, can use plain dev_kfree_skb() just fine?

I don't think they are fine, I just don't see bug reports
for them. At very least, I saw a same bug report for be2net too.

To reproduce this bug, we need to find some one calling printk()
within IRQ handler, which seems rare? It seems there are few
people using hpsa driver together with netconsole.
