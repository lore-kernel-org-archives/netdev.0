From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Tue, 02 Sep 2014 15:03:26 -0700 (PDT)
Message-ID: <20140902.150326.1420682815750767731.davem@davemloft.net>
References: <1409133238.26515.13.camel@localhost>
	<1409650573.1808.11.camel@jlt4.sipsolutions.net>
	<540675F2.1030308@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org
To: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <540675F2.1030308-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Date: Wed, 03 Sep 2014 10:59:14 +0900

> Upper-layer needs to cope eith situation of seeing packets with
> "incorrect" L2 header anyway (e.g., in promiscous mode).
> I do not see much advantage to drop them here.

It's required to prevent wireless nodes from using the shared wireless
group keys (used for multicast transmission) to inject unicast frames.

The RFCs really do specify this at least on the ipv4 side.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
