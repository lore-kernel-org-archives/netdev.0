From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] inet_peer : group together avl_left, avl_right,
 v4daddr to speedup lookups on some CPUS
Date: Fri, 20 Oct 2006 00:28:45 -0700 (PDT)
Message-ID: <20061020.002845.17865316.davem@davemloft.net>
References: <200610171458.37636.dada1@cosmosbay.com>
	<200610180938.39175.dada1@cosmosbay.com>
	<200610191257.42549.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992554AbWJTH3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 03:29:03 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610191257.42549.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 19 Oct 2006 12:57:42 +0200

> Lot of routers/embedded devices still use CPUS with 16/32 bytes cache lines. 
> (486, Pentium, ...  PIII)
> It makes sense to group together fields used at lookup time so they fit in one 
> cache line.
> This reduce cache footprint and speedup lookups.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
