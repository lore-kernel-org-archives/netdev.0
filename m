From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] udp_tunnel: Pass UDP socket down through
 udp_tunnel{,6}_xmit_skb().
Date: Tue, 07 Apr 2015 15:30:44 -0400 (EDT)
Message-ID: <20150407.153044.772260953305341361.davem@davemloft.net>
References: <20150405.221909.1825232827861250716.davem@davemloft.net>
	<CALx6S35rK35GFZAcqygjGNRUhC=vJx60TYLFDUeUd2bAim7Vzg@mail.gmail.com>
	<1428421534.2928.3.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbbDGTar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:30:47 -0400
In-Reply-To: <1428421534.2928.3.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 07 Apr 2015 17:45:34 +0200

> On Mo, 2015-04-06 at 23:02 -0700, Tom Herbert wrote:
>> On Sun, Apr 5, 2015 at 7:19 PM, David Miller <davem@davemloft.net> wrote:
>> > diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
>> > index b6a211a..5cafd92 100644
>> > --- a/net/ipv6/ip6_tunnel.c
>> > +++ b/net/ipv6/ip6_tunnel.c
>> > @@ -1100,7 +1100,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
>> >         ipv6h->nexthdr = proto;
>> >         ipv6h->saddr = fl6->saddr;
>> >         ipv6h->daddr = fl6->daddr;
>> > -       ip6tunnel_xmit(skb, dev);
>> > +       ip6tunnel_xmit(NULL, skb, dev);
>> 
>> By same should logic iptunnel_xmit call in ip_tunnel_xmit should take
>> NULL arg for socket?
> 
> Sure!
> 
> Thanks, otherwise the patches look good!
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Ok I've made this adjustment and will push the series out, thanks everyone.
