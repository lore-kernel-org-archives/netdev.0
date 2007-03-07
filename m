From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Multipath routing in Linux 2.6
Date: Wed, 7 Mar 2007 08:39:32 +0100
Message-ID: <20070307073932.GA1675@ff.dom.local>
References: <45EDD0E3.3000906@linpro.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tore Anderson <tore@linpro.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:53466 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161296AbXCGHfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 02:35:34 -0500
Content-Disposition: inline
In-Reply-To: <45EDD0E3.3000906@linpro.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-03-2007 21:36, Tore Anderson wrote:
> 
>   Hello list,
> 
>   I've been trying to figure out how to make equal-cost multipath
>  routing work, with no luck.  Asked on the LARTC list with no success,

It is probably one of the most often asked questions
on the LARTC, so I'd suggest to look at its archives.

>   I'm sending traffic from a relatively busy network to this table:
...
>   I've tried loading and unloading the multipath_{wrandom,rr,random,drr}

Multipath with caching doesn't work with forwarding.
...
>   I feel I'm missing something essential here but I have no idea what.
>  Google only tells me about others having roughly the same problem but
>  never any solution. [...]

It must be this fake google.

Some wrandom suggestions:

CONFIG_IP_ROUTE_MULTIPATH = y
CONFIG_IP_ROUTE_MULTIPATH_CACHED = n
rp_filter turned off
iptables CONNMARK or Julian Anastasov's patch
more ip route ... & ip rule ...
go to the LARTC again with: why still doesn't work...

Regards,
Jarek P.
