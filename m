From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] rtnetlink: Fix message size calculation for link messages
Date: Fri, 12 Nov 2010 08:43:46 +0100
Message-ID: <4CDCF032.7040802@trash.net>
References: <20101112014759.GA8491@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56103 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052Ab0KLHnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 02:43:47 -0500
In-Reply-To: <20101112014759.GA8491@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.11.2010 02:47, Thomas Graf wrote:
> nlmsg_total_size() calculates the length of a netlink message
> including header and alignment. nla_total_size() calculates the
> space an individual attribute consumes which was meant to be used
> in this context.
> 
> Also, ensure to account for the attribute header for the
> IFLA_INFO_XSTATS attribute as implementations of get_xstats_size()
> seem to assume that we do so.
> 
> The addition of two message headers minus the missing attribute
> header resulted in a calculated message size that was larger than
> required. Therefore we never risked running out of skb tailroom.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>
> Cc: Patrick McHardy <kaber@trash.net>

Looks good to me, thanks Thomas.

Acked-by: Patrick McHardy <kaber@trash.net>
