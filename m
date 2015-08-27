From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net/mlx4_core: Capping number of
 requested MSIXs to MAX_MSIX
Date: Thu, 27 Aug 2015 16:40:45 -0700 (PDT)
Message-ID: <20150827.164045.1144012065560840409.davem@davemloft.net>
References: <1440704606-20452-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, matanb@mellanox.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbH0Xkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:40:46 -0400
In-Reply-To: <1440704606-20452-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clsoto@linux.vnet.ibm.com
Date: Thu, 27 Aug 2015 14:43:25 -0500

> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
> 
> We currently manage IRQs in pool_bm which is a bit field
> of MAX_MSIX bits. Thus, allocating more than MAX_MSIX
> interrupts can't be managed in pool_bm.
> Fixing this by capping number of requested MSIXs to
> MAX_MSIX.
> 
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Applied.
