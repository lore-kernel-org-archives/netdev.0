From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 v2] Fix dst_neigh_lookup/dst_neigh_lookup_skb
 return value handling bug
Date: Fri, 15 Mar 2013 09:07:31 -0400 (EDT)
Message-ID: <20130315.090731.903984549150746717.davem@davemloft.net>
References: <1363317710-30151-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yizhouzhou@ict.ac.cn
To: zhouzhouyi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829Ab3CONHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 09:07:15 -0400
In-Reply-To: <1363317710-30151-1-git-send-email-zhouzhouyi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Date: Fri, 15 Mar 2013 11:21:50 +0800

> When neighbour table is full, dst_neigh_lookup/dst_neigh_lookup_skb will return
> -ENOBUFS which is absolutely non zero, while all the code in kernel which use 
> above functions assume failure only on zero return which will cause panic. (for
> example: : https://bugzilla.kernel.org/show_bug.cgi?id=54731).
> 
> This patch corrects above error with smallest changes to kernel source code and
> also correct two return value check missing bugs in drivers/infiniband/hw/cxgb4/cm.c
> 
> Tested on my x86_64 SMP machine
> 
> Reported-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
> Tested-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
> Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>

Applied.
