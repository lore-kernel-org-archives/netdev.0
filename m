From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: sparse checking prevented by "net: fix kmemcheck annotations"
Date: Mon, 01 Mar 2010 17:18:06 +0100
Message-ID: <4B8BE8BE.9070505@s5r6.in-berlin.de>
References: <4B8BAE79.9000609@s5r6.in-berlin.de> <1267448966.3039.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:55183 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab0CAQSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 11:18:12 -0500
In-Reply-To: <1267448966.3039.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH] net: fix protocol sk_buff field
> 
> Commit e992cd9b72a18 (kmemcheck: make bitfield annotations truly no-ops
> when disabled) allows us to revert a workaround we did in the past to
> not add holes in sk_buff structure.
> 
> This patch partially reverts commit 14d18a81b5171
> (net: fix kmemcheck annotations) so that sparse doesnt complain:
> 
> include/linux/skbuff.h:357:41: error: invalid bitfield specifier for
> type restricted __be16.

Great, very appreciated.
-- 
Stefan Richter
-=====-==-=- --== ----=
http://arcgraph.de/sr/
