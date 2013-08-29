From: Patrick McHardy <kaber@trash.net>
Subject: Re: [nf-next PATCH] netfilter: SYNPROXY let unrelated packets
 continue
Date: Thu, 29 Aug 2013 12:11:17 +0200
Message-ID: <20130829101117.GA14229@macbook.localnet>
References: <20130829101625.14346.41071.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, as@one.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52268 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069Ab3H2KLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 06:11:21 -0400
Content-Disposition: inline
In-Reply-To: <20130829101625.14346.41071.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 29, 2013 at 12:18:46PM +0200, Jesper Dangaard Brouer wrote:
> Packets reaching SYNPROXY were default dropped, as they were most
> likely invalid (given the recommended state matching).  This
> patch, changes SYNPROXY target to let packets, not consumed,
> continue being processed by the stack.
> 
> This will be more in line other target modules. As it will allow
> more flexible configurations of handling, logging or matching on
> packets in INVALID states.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Patrick McHardy <kaber@trash.net>

> ---
> comments:
>  - This patch depend applying the TCP flags fix patch send earlier
>  - This replaces my patch: "netfilter: Extend SYNPROXY with a --continue option"
