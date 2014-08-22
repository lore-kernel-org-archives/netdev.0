From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xgene: fix possible NULL dereference in
 xgene_enet_free_desc_rings()
Date: Fri, 22 Aug 2014 11:25:41 -0700 (PDT)
Message-ID: <20140822.112541.279712306018396613.davem@davemloft.net>
References: <1408653888-10193-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487AbaHVSZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:25:42 -0400
In-Reply-To: <1408653888-10193-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu, 21 Aug 2014 13:44:48 -0700

> A NULL pointer dereference is possible for the argument ring->buf_pool
> which is passed to xgene_enet_free_desc_ring(), as ring could be NULL.
> 
> And now since NULL pointers are being checked for before the calls to
> xgene_enet_free_desc_ring(), might as well take advantage of them and
> not call the function if the argument would be NULL.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Applied, thanks.
