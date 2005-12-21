From: Chris Leech <chris.leech@gmail.com>
Subject: Fwd: [RFC][PATCH 4/5] I/OAT DMA support and TCP acceleration
Date: Tue, 20 Dec 2005 23:10:07 -0800
Message-ID: <41b516cb0512202310q78d5a25apab3c9d6fbb17089e@mail.gmail.com>
References: <1135142263.13781.21.camel@cleech-mobl>
	 <43A8F43B.6020307@cosmosbay.com>
	 <41b516cb0512202305p45439464o6b7ba6c2c88062bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932295AbVLUHKK@vger.kernel.org>
To: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
In-Reply-To: <41b516cb0512202305p45439464o6b7ba6c2c88062bc@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, bounced from vger the first time due to formatting

---------- Forwarded message ----------
From: Chris Leech <christopher.leech@intel.com>
Date: Dec 20, 2005 11:05 PM
Subject: Re: [RFC][PATCH 4/5] I/OAT DMA support and TCP acceleration
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: lkml <linux-kernel@vger.kernel.org>, netdev
<netdev@vger.kernel.org>, "Grover, Andrew" <andrew.grover@intel.com>,
"Ronciak, John" <john.ronciak@intel.com>

On 12/20/05, Eric Dumazet <dada1@cosmosbay.com> wrote:
>  Please consider not enlarging cb[] if not CONFIG_NET_DMA ?
>
> I mean, most machines wont have a compatable NIC, so why should they pay the
> price (memory, cpu) in a critical structure named sk_buff ?
>
> #ifdef CONFIG_NET_DMA
> typedef dma_cookie_t net_dma_cookie_t;
> #else
> typedef struct {} net_dma_cookie_t;
> #endif
>
> ...
>
>         char   cb[40+sizeof(net_dma_cookie_t)];
>

 That could be a good way to deal with it.  Actually, I should double
check the length of tcp_skb_cb.  I took a quick look and thought that
there might be some room left there anyway, even though the comment in
tcp.h says otherwise.

 -Chris
