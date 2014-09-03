From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 03 Sep 2014 14:01:22 +0200
Message-ID: <1409745682.14224.10.camel@localhost>
References: <1409133238.26515.13.camel@localhost>
	 <1409650573.1808.11.camel@jlt4.sipsolutions.net>
	 <540675F2.1030308@miraclelinux.com>
	 <20140902.150326.1420682815750767731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140902.150326.1420682815750767731.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Di, 2014-09-02 at 15:03 -0700, David Miller wrote:
> From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
> Date: Wed, 03 Sep 2014 10:59:14 +0900
> 
> > Upper-layer needs to cope eith situation of seeing packets with
> > "incorrect" L2 header anyway (e.g., in promiscous mode).
> > I do not see much advantage to drop them here.
> 
> It's required to prevent wireless nodes from using the shared wireless
> group keys (used for multicast transmission) to inject unicast frames.
> 
> The RFCs really do specify this at least on the ipv4 side.

I have to agree with YOSHIFUJI Hideaki here. I looked at a lot of RFCs
and haven't found anything were it states to use L2 address type for
checks in L3 ipv6 addresses. For IPv4 addresses the situation is clear
though...

There was an RFC update (6085) which specifically allows one to send
ipv6 multicast frames with unicast L2 addresses. In the dicussion that
lead to this RFC it was stated that checking L2 and L3 addresses seems
to be a layering violation, but I can just use this as a hint.

Bye,
Hannes


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
