From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nets: Introduce read_pnet() and write_pnet() helpers
Date: Wed, 12 Nov 2008 00:53:42 -0800 (PST)
Message-ID: <20081112.005342.156066202.davem@davemloft.net>
References: <20081111111946.GD3665@x200.localdomain>
	<20081111.164554.143409564.davem@davemloft.net>
	<491A75BE.1010907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750973AbYKLIxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 03:53:43 -0500
In-Reply-To: <491A75BE.1010907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 12 Nov 2008 07:20:46 +0100

> [PATCH] nets: Introduce read_pnet() and write_pnet() helpers
> 
> This patch introduces two helpers that deal with reading and writing
> struct net pointers in various network structures.
> 
> Their implementation depends on CONFIG_NET_NS
> 
> For symmetry, both functions work with "struct net **pnet".
> 
> Their usage should reduce the number of #ifdef CONFIG_NET_NS,
> without adding many helpers for each network structure
> that hold a "struct net *pointer"
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
