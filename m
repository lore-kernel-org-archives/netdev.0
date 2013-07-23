From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] pktgen: Add UDPCSUM flag to support UDP
 checksums
Date: Tue, 23 Jul 2013 18:15:45 +0100
Message-ID: <20130723171545.GB16761@casper.infradead.org>
References: <7a919a32ea457c580cf35c3a1b394d5ff041a441.1374596306.git.tgraf@suug.ch>
 <1374597252.3449.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58501 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756755Ab3GWRPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 13:15:47 -0400
Content-Disposition: inline
In-Reply-To: <1374597252.3449.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/13 at 09:34am, Eric Dumazet wrote:
> > @@ -2747,11 +2755,31 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
> >  	iph->frag_off = 0;
> >  	iplen = 20 + 8 + datalen;
> >  	iph->tot_len = htons(iplen);
> > -	iph->check = 0;
> > -	iph->check = ip_fast_csum((void *)iph, iph->ihl);
> 
> This seems not relevant to your patch.

I'll split this into a separate patch.

> What about IPv6 side ?

IPv6 is dead ;-) Just kidding, I'll add the bits in case someone
thinks otherwise.
