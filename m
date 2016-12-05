From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 12:40:00 +0100
Message-ID: <trinity-efd00e93-2b37-4543-a199-e2cbed9fe455-1480937999976@3capp-gmx-bs18>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd> <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>,
 <20161205101516.GA24936@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, "David Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Pavel Machek" <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205101516.GA24936@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> 
> Actually, I was wrong. irqlock protection is needed, since
> stmmac_tx_clean() is called from timer, and that's interrupt context,
> as you can confirm using BUG_ON(in_interrupt());
> 

in_interrupt() can mean both softirq and hardirq context. In this case it
means softirq. So I guess you were right before, and no irq locking is needed.

Regards,
Lino
