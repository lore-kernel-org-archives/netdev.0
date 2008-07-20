From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Sun, 20 Jul 2008 10:58:14 -0400
Message-ID: <1216565894.4847.61.camel@localhost>
References: <487F4327.1000107@trash.net>
	 <1216301732.4726.26.camel@localhost> <487F50EC.80008@trash.net>
	 <20080717.152447.89672084.davem@davemloft.net> <487FDA67.30902@trash.net>
	 <1216386624.4833.94.camel@localhost>  <adaljzz6ruq.fsf@cisco.com>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <adaljzz6ruq.fsf-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-18-07 at 10:10 -0700, Roland Dreier wrote:

> This is definitely true, but it is good to keep in mind that in the near
> future we will start to see things look a little like multiple "virtual
> wires."  This is because of new ethernet standards like per-priority
> pause, which makes it possible that one hardware ring on a NIC can
> transmit while another ring is paused (possibly because of congestion
> far off in the network).

Thats essentially what i am arguing for.
[I think some, not all, of the wireless qos schemes also have similar
scheduling].

My understanding of these wired "datacentre/virtualization" schemes you
describe is they are strict prio based. When the low prio "virtual wire"
is contending for the "physical wire" with a higher prio "virtual wire",
the high prio always wins. 
We just need to make sure this behavior is also maintained whatever
buffering scheme is used within or above the driver(qdisc level).

cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
