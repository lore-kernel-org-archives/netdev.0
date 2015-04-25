From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 3/6] ipv6: netfilter: remove unnecessary braces
Date: Sat, 25 Apr 2015 08:59:02 -0700
Message-ID: <1429977542.32250.12.camel@perches.com>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
	 <1429954020-11763-4-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0215.hostedemail.com ([216.40.44.215]:49871 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1030227AbbDYP7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 11:59:05 -0400
In-Reply-To: <1429954020-11763-4-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-25 at 10:26 +0100, Ian Morris wrote:
> Remove braces from a few if statements where not required.

trivia:

> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
[]
> @@ -151,9 +151,8 @@ ip6_packet_match(const struct sk_buff *skb,
>  				ip6info->proto);
>  
>  		if (ip6info->proto == protohdr) {
> -			if (ip6info->invflags & IP6T_INV_PROTO) {
> +			if (ip6info->invflags & IP6T_INV_PROTO)
>  				return false;
> -			}
>  			return true;

maybe
			return (!(ip6info->invflags & IP6T_INV_PROTO));
