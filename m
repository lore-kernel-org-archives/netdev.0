From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net/mlx4_core: double free of dev_vfs
Date: Wed, 03 Jun 2015 20:13:16 -0700 (PDT)
Message-ID: <20150603.201316.399083762227205850.davem@davemloft.net>
References: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbFDDNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:13:17 -0400
In-Reply-To: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clsoto@linux.vnet.ibm.com
Date: Tue,  2 Jun 2015 16:07:23 -0500

> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
> 
> If user loads mlx4_core with num_vfs greater than
> supported then variable dev->dev_vfs is freed 2 times after unloading the
> driver.
> 
> Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Applied.
