From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: frag , remove an empty ifdef.
Date: Wed, 19 Jun 2013 23:07:46 -0700 (PDT)
Message-ID: <20130619.230746.1574933720000310714.davem@davemloft.net>
References: <1371326696-32561-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376Ab3FTGHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 02:07:47 -0400
In-Reply-To: <1371326696-32561-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Sat, 15 Jun 2013 23:04:56 +0300

> This patch removes an empty ifdef from inet_frag_intern()
> in net/ipv4/inet_fragment.c.
> 
> commit b67bfe0d42cac56c512dd5da4b1b347a23f4b70a
> (hlist: drop the node parameter from iterators) removed hlist from
> net/ipv4/inet_fragment.c, but did not remove the enclosing ifdef command,
> which is now empty.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
