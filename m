From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/key/af_key.c: add missing kfree_skb
Date: Fri, 13 Apr 2012 11:05:38 -0400 (EDT)
Message-ID: <20120413.110538.449625213257927113.davem@davemloft.net>
References: <1333960870-19735-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab2DMPHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 11:07:46 -0400
In-Reply-To: <1333960870-19735-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon,  9 Apr 2012 10:41:10 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> At the point of this error-handling code, alloc_skb has succeded, so free
> the resulting skb by jumping to the err label.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
