From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to
 ip6_route_output
Date: Wed, 22 Jul 2015 13:03:14 -0700 (PDT)
Message-ID: <20150722.130314.1100446681284682783.davem@davemloft.net>
References: <20150722122309.GB968@pox.localdomain>
	<20150722.104926.1502608671575195516.davem@davemloft.net>
	<55AFEF4B.6070702@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbbGVUDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 16:03:18 -0400
In-Reply-To: <55AFEF4B.6070702@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Wed, 22 Jul 2015 12:30:19 -0700

> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
> index 5c467ef..2b28615 100644
> --- a/net/mpls/Kconfig
> +++ b/net/mpls/Kconfig
> @@ -24,6 +24,8 @@ config NET_MPLS_GSO
> 
>  config MPLS_ROUTING
>         tristate "MPLS: routing support"
> +       depends on INET
> +       depends on IPV6
>         ---help---
>          Add support for forwarding of mpls packets.

Having to enable IPV6 in order to use MPLS is not reasonable.

You have to seperate out the individual components and give
the user a choice in the matter.
