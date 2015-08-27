From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net/mlx4_core: Fix unintialized variable
 used in error path
Date: Thu, 27 Aug 2015 16:40:50 -0700 (PDT)
Message-ID: <20150827.164050.880561086607353807.davem@davemloft.net>
References: <1440704606-20452-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<1440704606-20452-2-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, matanb@mellanox.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbH0Xkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:40:51 -0400
In-Reply-To: <1440704606-20452-2-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clsoto@linux.vnet.ibm.com
Date: Thu, 27 Aug 2015 14:43:26 -0500

> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
> 
> The uninitialized value name in mlx4_en_activate_cq was used in order
> to print an error message. Fixing it by replacing it with cq->vector.
> 
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Applied.
