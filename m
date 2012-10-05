From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 05 Oct 2012 17:37:05 +0200
Message-ID: <1349451425.21172.119.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
	 <1349422868.21172.38.camel@edumazet-glaptop>
	 <1349434194.16710.44.camel@sakura.staff.proxad.net>
	 <1349439732.21172.52.camel@edumazet-glaptop>
	 <1349441509.28867.17.camel@sakura.staff.proxad.net>
	 <1349442173.21172.66.camel@edumazet-glaptop>
	 <1349448659.28867.27.camel@sakura.staff.proxad.net>
	 <1349449440.21172.118.camel@edumazet-glaptop>
	 <1349450151.28867.33.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: mbizon@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349450151.28867.33.camel@sakura.staff.proxad.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-05 at 17:15 +0200, Maxime Bizon wrote:

> You think removing skb_recycle() is too big a change for stable ?
> 
> Driver change is simple, as recycling is not guaranteed today you have
> this:
> 
>  if (!try_recycle(skb))
>     skb = alloc_skb()
> > 
> we just remove the try_recycle part, we are not adding any new code
> path.
> 
> 
> I'm not the right person to give you a correct NET_SKB_PAD value, I have
> a lot of out of tree patches in my kernels, some custom drivers as well
> that needs quite a lot of headroom, and uncommon network setup.
> 

OK, I'll send the patch to remove skb_recycle()
