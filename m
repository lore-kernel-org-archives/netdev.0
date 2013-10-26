From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next 3/5] 6lowpan: use
 netdev_alloc_skb instead dev_alloc_skb
Date: Fri, 25 Oct 2013 23:01:44 -0700
Message-ID: <1382767304.5595.1.camel@joe-AO722>
References: <1382647904-11311-1-git-send-email-alex.aring@gmail.com>
	<1382647904-11311-4-git-send-email-alex.aring@gmail.com>
	<20131026.014214.1636999222808937267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20131026.014214.1636999222808937267.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-10-26 at 01:42 -0400, David Miller wrote:
> From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 24 Oct 2013 22:51:42 +0200
> 
> > @@ -1127,12 +1127,12 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
> >  
> >  	lowpan_raw_dump_inline(__func__, "6lowpan fragment header", head, hlen);
> >  
> > -	frag = dev_alloc_skb(hlen + mlen + plen + IEEE802154_MFR_SIZE);
> > +	frag = netdev_alloc_skb(skb->dev, hlen + mlen +
> > +			plen + IEEE802154_MFR_SIZE);
> 
> Please indent this properly.
> 
> It should be something like:
> 
> 	frag = netdev_alloc_skb(skb->dev, hlen + mlen +
> 					  plen + IEEE802154_MFR_SIZE);

Maybe better as:

	frag = netdev_alloc_skb(skb->dev,
				hlen + mlen + plen + IEEE802154_MFR_SIZE);



------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60135991&iu=/4140/ostg.clktrk
