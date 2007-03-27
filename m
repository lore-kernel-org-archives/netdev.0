From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : align inet_protos[] on SMP
Date: Tue, 27 Mar 2007 14:20:17 -0700 (PDT)
Message-ID: <20070327.142017.52167359.davem@davemloft.net>
References: <20070327154704.cd85d943.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965442AbXC0VUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:20:18 -0400
In-Reply-To: <20070327154704.cd85d943.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 27 Mar 2007 15:47:04 +0200

> As IPPROTO_TCP is 6, it makes sense to make sure inet_protos[] array is properly cache line aligned to avoid false sharing on SMP.
> 
> c0680540 b peer_total
> c0680544 b inet_peer_unused_head
> c0680560 B inet_protos
> 
> On i386 this example, we can see that inet_protos[IPPROTO_TCP] shares a potentially hot (and modified) cache line.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks again Eric.

We could probably add some const markings to these things as well.
