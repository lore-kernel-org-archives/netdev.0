From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 : ICMPV6_DEST_UNREACH type with ICMPV6_NOROUTE code
Date: Fri, 09 May 2003 20:44:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509.204403.72834600.yoshfuji@linux-ipv6.org>
References: <003e01c313b8$e55db620$28acfe81@seong>
	<16059.37474.453731.39031@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: seong@etri.re.kr, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16059.37474.453731.39031@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <16059.37474.453731.39031@robur.slu.se> (at Fri, 9 May 2003 13:34:58 +0200), Robert Olsson <Robert.Olsson@data.slu.se> says:

>  > the kernel must send an ICMPV6_DEST_UNREACH icmp message with ICMPV6_NOROUTE
>  > code.
>  > How about you ? Am I right ?
> 
>  I think you are...
> 
> --- linux/net/ipv6/route.c.030508       2003-03-24 23:01:14.000000000 +0100
> +++ linux/net/ipv6/route.c      2003-05-09 13:29:31.000000000 +0200
> @@ -1166,7 +1166,7 @@
>  int ip6_pkt_discard(struct sk_buff *skb)
>  {
>         IP6_INC_STATS(Ip6OutNoRoutes);
> -       icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0, skb->dev);
> +       icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_NOROUTE, 0, skb->dev);
>         kfree_skb(skb);
>         return 0;
>  }

Yes, code is already in the tree.  Thanks.

--yoshfuji
