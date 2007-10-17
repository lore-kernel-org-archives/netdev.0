From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Fix memory leak in cleanup_ipv6_mibs()
Date: Wed, 17 Oct 2007 09:23:39 -0700
Message-ID: <OF35572218.B832B62B-ON88257377.0059DA35-88257377.0059F648@us.ibm.com>
References: <47161662.2080706@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, devel@openvz.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47453 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbXJQQXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 12:23:45 -0400
In-Reply-To: <47161662.2080706@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: David L Stevens <dlstevens@us.ibm.com>
 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index bc92938..1b1caf3 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -747,6 +747,7 @@ static void cleanup_ipv6_mibs(void)
>  {
>     snmp_mib_free((void **)ipv6_statistics);
>     snmp_mib_free((void **)icmpv6_statistics);
> +   snmp_mib_free((void **)icmpv6msg_statistics);
>     snmp_mib_free((void **)udp_stats_in6);
>     snmp_mib_free((void **)udplite_stats_in6);
>  }
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

