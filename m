From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: coding style: Use pointer after check
Date: Sun, 07 Jun 2015 23:46:31 -0700 (PDT)
Message-ID: <20150607.234631.405943391269310676.davem@davemloft.net>
References: <1433735691-7922-1-git-send-email-firogm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, eric.dumazet@gmail.com, wharms@bfs.de,
	julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: firogm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbbFHGqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 02:46:33 -0400
In-Reply-To: <1433735691-7922-1-git-send-email-firogm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Firo Yang <firogm@gmail.com>
Date: Mon,  8 Jun 2015 11:54:51 +0800

> As Alexander Duyck pointed out that:
> struct tnode {
>         ...
>         struct key_vector kv[1];
> }
> The kv[1] member of struct tnode is an arry that refernced by
> a null pointer will not crash the system, like this:
> struct tnode *p = NULL;
> struct key_vector *kv = p->kv;
> As such p->kv doesn't actually dereference anything, it is simply a
> means for getting the offset to the array from the pointer p.
> 
> This patch make the code more regular to avoid making people feel
> odd when they look at the code.
> 
> Signed-off-by: Firo Yang <firogm@gmail.com>

Applied.
