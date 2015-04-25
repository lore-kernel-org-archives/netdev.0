From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/6] ipv6: netfilter: whitespace in line layouts
Date: Sat, 25 Apr 2015 08:57:02 -0700
Message-ID: <1429977422.32250.10.camel@perches.com>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
	 <1429954020-11763-3-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0052.hostedemail.com ([216.40.44.52]:49788 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1030227AbbDYP5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 11:57:11 -0400
In-Reply-To: <1429954020-11763-3-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-25 at 10:26 +0100, Ian Morris wrote:
> Try to improve coding readability by adding spaces in line layouts. No
> changes to functionality. No changes according to objdiff.

trivia:

> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
[]
> @@ -44,13 +44,13 @@ MODULE_DESCRIPTION("IPv6 packet filter");
>  /*#define DEBUG_IP_FIREWALL_USER*/
>  
>  #ifdef DEBUG_IP_FIREWALL
> -#define dprintf(format, args...) pr_info(format , ## args)
> +#define dprintf(format, args...) pr_info(format, ## args)

At least for new code, use of
	#define foo(args...) ##args
seems to be supplanted by
	#define foo(...) ##__VA_ARGS__

Dunno if that warrants changing them though

> @@ -126,14 +126,14 @@ ip6_packet_match(const struct sk_buff *skb,
[]
>  /* ... might want to do something with class and flowlabel here ... */
>  
>  	/* look for the desired protocol header */
> -	if((ip6info->flags & IP6T_F_PROTO)) {
> +	if ((ip6info->flags & IP6T_F_PROTO)) {

Maybe you could remove the unnecessary extra parentheses
