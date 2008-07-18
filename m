From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Fri, 18 Jul 2008 10:10:21 -0700
Message-ID: <adaljzz6ruq.fsf@cisco.com>
References: <487F4327.1000107@trash.net> <1216301732.4726.26.camel@localhost>
	<487F50EC.80008@trash.net>
	<20080717.152447.89672084.davem@davemloft.net>
	<487FDA67.30902@trash.net> <1216386624.4833.94.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216386624.4833.94.camel@localhost> (jamal's message of "Fri, 18
	Jul 2008 09:10:24 -0400")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > The question is whether the packets sitting on the fifo qdisc are being
 > sorted fairly when congestion kicks in. Remember there is still a single
 > wire still even on multiple rings;->

This is definitely true, but it is good to keep in mind that in the near
future we will start to see things look a little like multiple "virtual
wires."  This is because of new ethernet standards like per-priority
pause, which makes it possible that one hardware ring on a NIC can
transmit while another ring is paused (possibly because of congestion
far off in the network).

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
