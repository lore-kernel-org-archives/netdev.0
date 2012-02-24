From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] gre: fix spelling in comments
Date: Fri, 24 Feb 2012 19:17:25 +0000
Message-ID: <1330111045.2397.14.camel@bwh-desktop>
References: <20120224100820.227ed31c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26455 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757341Ab2BXTR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 14:17:29 -0500
In-Reply-To: <20120224100820.227ed31c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-24 at 10:08 -0800, Stephen Hemminger wrote:
> The original spelling and bad word choice makes these comments hard to read.

Not to mention weird capitalisation.

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/ipv4/ip_gre.c	2012-02-24 10:04:41.007678920 -0800
> +++ b/net/ipv4/ip_gre.c	2012-02-24 10:07:54.421769389 -0800
> @@ -65,7 +65,7 @@
>     it is infeasible task. The most general solutions would be
>     to keep skb->encapsulation counter (sort of local ttl),

'ttl' is an abbreviation, and not a variable name here, so should be
capitalised.

>     and silently drop packet when it expires. It is a good
> -   solution, but it supposes maintaing new variable in ALL
> +   solution, but it supposes maintaining new variable in ALL
>     skb, even if no tunneling is used.
>  
>     Current solution: xmit_recursion breaks dead loops. This is a percpu
> @@ -91,14 +91,14 @@
>  
>     One of them is to parse packet trying to detect inner encapsulation
>     made by our node. It is difficult or even impossible, especially,
> -   taking into account fragmentation. TO be short, tt is not solution at all.
> +   taking into account fragmentation. TO be short, ttl is not solution at all.

'TO' shouldn't be capitalised.

>  
>     Current solution: The solution was UNEXPECTEDLY SIMPLE.

'UNEXPECTEDLY SIMPLE' shouldn't be capitalised.  Also, after the passage
of a few years, this is perhaps no longer unexpected at all...

>     We force DF flag on tunnels with preconfigured hop limit,
>     that is ALL. :-) Well, it does not remove the problem completely,
>     but exponential growth of network traffic is changed to linear
>     (branches, that exceed pmtu are pruned) and tunnel mtu

'pmtu' and 'mtu' should be capitalised.

> -   fastly degrades to value <68, where looping stops.
> +   rapidly degrades to value <68, where looping stops.
>     Yes, it is not good if there exists a router in the loop,
>     which does not force DF, even when encapsulating packets have DF set.
>     But it is not our problem! Nobody could accuse us, we made
> @@ -457,8 +457,8 @@ static void ipgre_err(struct sk_buff *sk
>     GRE tunnels with enabled checksum. Tell them "thank you".
>  
>     Well, I wonder, rfc1812 was written by Cisco employee,

'rfc' should be capitalised.

> -   what the hell these idiots break standrads established
> -   by themself???
> +   what the hell these idiots break standards established
> +   by themselves???
>   */
>  
>  	const struct iphdr *iph = (const struct iphdr *)skb->data;

Insults also detract from the readability as a technical description.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
