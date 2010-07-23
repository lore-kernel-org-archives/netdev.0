From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_nat_core: merge the same lines
Date: Fri, 23 Jul 2010 13:28:48 +0200
Message-ID: <4C497CF0.3000203@trash.net>
References: <1279792140-10445-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35924 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586Ab0GWL2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:28:44 -0400
In-Reply-To: <1279792140-10445-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.07.2010 11:49, Changli Gao wrote:
> nf_nat_core: merge the same lines

Please prefix your subjects with "netfilter: " so I don't have to
edit them every time.

> proto->unique_tuple() will be called finally, if the previous calls fail. This
> patch checks the false condition of (range->flags & IP_NAT_RANGE_PROTO_RANDOM)
> instead to avoid duplicate line of code: proto->unique_tuple().

Applied, thanks.
