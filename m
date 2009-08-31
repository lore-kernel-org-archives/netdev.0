From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch, v2] IPVS: Add handling of incoming ICMPV6 messages
Date: Mon, 31 Aug 2009 16:23:38 +0200
Message-ID: <4A9BDCEA.1090008@trash.net>
References: <20090831075904.GA3430@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Julius Volz <julius.volz@gmail.com>,
	Rob Gallagher <robert.gallagher@heanet.ie>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62934 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbZHaOXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 10:23:41 -0400
In-Reply-To: <20090831075904.GA3430@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
> From: Julius Volz <julius.volz@gmail.com>
> 
> IPVS: Add handling of incoming ICMPV6 messages
> 
> Add handling of incoming ICMPv6 messages.
> This follows the handling of IPv4 ICMP messages.
> 
> Amongst ther things this problem allows IPVS to behave sensibly
> when an ICMPV6_PKT_TOOBIG message is received:
> 
>     This message is received when a realserver sends a packet >PMTU to the
>     client. The hop on this path with insufficient MTU will generate an
>     ICMPv6 Packet Too Big message back to the VIP. The LVS server receives
>     this message, but the call to the function handling this has been
>     missing. Thus, IPVS fails to forward the message to the real server,
>     which then does not adjust the path MTU. This patch adds the missing
>     call to ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.
> 
>     Thanks to Rob Gallagher from HEAnet for reporting this issue and for
>     testing this patch in production (with direct routing mode).

Applied, thanks.
