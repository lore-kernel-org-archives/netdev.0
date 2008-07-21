From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Mon, 21 Jul 2008 08:09:01 -0700 (PDT)
Message-ID: <20080721.080901.214889979.davem@davemloft.net>
References: <20080721131918.GA11114@gondor.apana.org.au>
	<1216648585.4847.303.camel@localhost>
	<20080721135846.GA11543@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080721135846.GA11543-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Mon, 21 Jul 2008 21:58:46 +0800

> On Mon, Jul 21, 2008 at 09:56:25AM -0400, jamal wrote:
> > 
> > Ok - You may be able to pull it if you have the exact same hashing on
> > hardware rx as it is on transmit stateless filtering.
> > I can see a traffic pattern that could be cooked to give some good
> > numbers in such a scenario;->
> 
> Actually you've hit it on the head, as an alternative to TX hashing
> on the packet content, we need to allow TX queue selection based on
> the current CPU ID.

This we should avoid, it would allow reordering within a flow.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
