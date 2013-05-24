From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: bug fix on returning an invalid nic descriptor
Date: Thu, 23 May 2013 18:57:04 -0700 (PDT)
Message-ID: <20130523.185704.1417837541186108953.davem@davemloft.net>
References: <1369274302-8118-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759223Ab3EXB5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 21:57:05 -0400
In-Reply-To: <1369274302-8118-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Thu, 23 May 2013 09:58:22 +0800

> In function be_get_nic_desc(), it will go through the descriptor array
> returned from f/w. By comparing the desc_type field, it determines whether
> there is a nic descriptor in the array or not. In the case of no nic
> descriptor, this function should return NULL.
> 
> The code may return an invalide descriptor, when there is no nic descriptor
> in the array and the desc_count is less than MAX_RESOURCE_DESC. In this case,
> even there is no nic descriptor, it will still return the lase descriptor
> since the i doesn't equal to MAX_RESOURCE_DESC.
> 
> This patch fix this issue by returning the descriptor when find it and return
> NULL for other cases.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>

Applied.
