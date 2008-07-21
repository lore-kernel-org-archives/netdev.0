From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Mon, 21 Jul 2008 07:20:01 -0400
Message-ID: <1216639201.4847.217.camel@localhost>
References: <1216566963.4847.81.camel@localhost>
	 <20080720.102534.246150854.davem@davemloft.net>
	 <1216593170.4847.137.camel@localhost>
	 <20080720.165911.86437240.davem@davemloft.net>
	 <1216606839.4847.159.camel@localhost>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216606839.4847.159.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-20-07 at 22:20 -0400, jamal wrote:

> We are in sync i think, a single pfifo per TX queue is the way to go. I
> was suggesting it goes in the driver, but this is cleaner: In the

Actually, can i modify that thought and go back to my initial contention
now that things are making more sense?;->
A single s/ware queue per hardware transmit queue is good - but that
being pfifo_fast would be a lot better. It would, in the minimal, keep
things as they were for non-multiq and is a sane choice for any virtual
wire.

cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
