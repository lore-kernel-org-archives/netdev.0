From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: WIZnet drivers: fix possible NULL dereference
Date: Fri, 13 Apr 2012 13:34:56 -0400 (EDT)
Message-ID: <20120413.133456.399965170986039906.davem@davemloft.net>
References: <20120410084006.GA27006@elgon.mountain>
	<1334123633-11833-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: msink@permonline.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab2DMRfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:35:04 -0400
In-Reply-To: <1334123633-11833-1-git-send-email-msink@permonline.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Sinkovsky <msink@permonline.ru>
Date: Wed, 11 Apr 2012 11:53:53 +0600

> This fixes possible null dereference in probe() function: when both 
> .mac_addr and .link_gpio are unknown, dev.platform_data may be NULL
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Mike Sinkovsky <msink@permonline.ru>

Applied.
