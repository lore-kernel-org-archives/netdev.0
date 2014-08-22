From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Fri, 22 Aug 2014 10:54:05 -0700 (PDT)
Message-ID: <20140822.105405.1982870131653082781.davem@davemloft.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	<alpine.LFD.2.11.1408212119510.1896@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: ja-FgGsKACvmQM@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.11.1408212119510.1896-c1lBKlETG9EWAawoAK+ZAw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Date: Thu, 21 Aug 2014 22:51:02 +0300 (EEST)

>>  	if (res.type == RTN_BROADCAST)
>>  		goto brd_input;
> 
> 	Is this place better, after checking for RTN_BROADCAST?
> 
> 	/* ARP link-layer broadcasts are acceptable here */
> 	if ((skb->pkt_type == PACKET_BROADCAST ||
> 	     skb->pkt_type == PACKET_MULTICAST) &&
> 	    skb->protocol == htons(ETH_P_IP))
> 		goto e_inval;

Indeed, this would make ARP happier, but that still leaves open the
issue of CLUSTERIP.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
