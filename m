From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [2.6 patch] unexport icmpmsg_statistics
Date: Wed, 24 Oct 2007 12:07:45 -0700
Message-ID: <OFD68B1480.9D9C7453-ON8825737E.0068B005-8825737E.0068FB84@us.ibm.com>
References: <20071024162410.GE30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:36618 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbXJXTIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 15:08:09 -0400
In-Reply-To: <20071024162410.GE30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote on 10/24/2007 09:24:10 AM:

> This patch removes the unused EXPORT_SYMBOL(icmpmsg_statistics).
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 4ce74657ac0b1bdcb4c7bc359d05643f8cc4a08b 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 272c69e..233de06 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -1104,5 +1104,4 @@ void __init icmp_init(struct net_proto_family 
*ops)
>  EXPORT_SYMBOL(icmp_err_convert);
>  EXPORT_SYMBOL(icmp_send);
>  EXPORT_SYMBOL(icmp_statistics);
> -EXPORT_SYMBOL(icmpmsg_statistics);
>  EXPORT_SYMBOL(xrlim_allow);

        "icmpmsg_statistics" belongs with (and replaces some of the 
old...)
"icmp_statistics". I'm not sure that any modules use it, but I think you
should remove both or neither.

                                                                +-DLS


