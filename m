From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Thu, 04 Oct 2012 18:50:06 +0200
Message-ID: <1349369406.16011.82.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349366521.2532.12.camel@sakura.staff.proxad.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-10-04 at 18:02 +0200, Maxime Bizon wrote:
> O
> 
> Since skb_recycle() resets skb->data using (skb->head + NET_SKB_PAD), a
> recycled skb going multiple times through a path that needs to expand
> skb head will get bigger and bigger each time, and you eventually end up
> with an allocation failure.
> 

Because there is not enough headroom ?

> An idea to fix this would be to pass needed skb size to skb_resize() and
> set skb->data to MIN(NET_SKB_PAD, (skb->end - skb->head - skb_size) / 2)

I am trying to decode this but I cant ;)

What is skb_resize() ?
and what do you mean setting skb->data to MIN(NET_SKB_PAD, (skb->end -
skb->head - skb_size) / 2)

Care to explain again your idea ?

Thanks !
