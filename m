From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] drivers/isdn/mISDN/stack.c: remove invalid
 reference to list iterator variable
Date: Mon, 09 Jul 2012 15:24:49 -0700 (PDT)
Message-ID: <20120709.152449.1208146051989927045.davem@davemloft.net>
References: <1341747464-1772-1-git-send-email-Julia.Lawall@lip6.fr>
	<1341747464-1772-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab2GIWYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:24:50 -0400
In-Reply-To: <1341747464-1772-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun,  8 Jul 2012 13:37:38 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> If list_for_each_entry, etc complete a traversal of the list, the iterator
> variable ends up pointing to an address at an offset from the list head,
> and not a meaningful structure.  Thus this value should not be used after
> the end of the iterator.  The dereferences are just deleted from the
> debugging statement.
> 
> This problem was found using Coccinelle (http://coccinelle.lip6.fr/).
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
