From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net/mlx4_core: need to call close fw if
 alloc icm is called twice
Date: Wed, 03 Jun 2015 20:13:21 -0700 (PDT)
Message-ID: <20150603.201321.78762441666787200.davem@davemloft.net>
References: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<1433279245-5577-2-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbbFDDNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:13:22 -0400
In-Reply-To: <1433279245-5577-2-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clsoto@linux.vnet.ibm.com
Date: Tue,  2 Jun 2015 16:07:24 -0500

> From: Carol Soto <clsoto@linux.vnet.ibm.com>
> 
> If mlx4_enable_sriov is called by adapter without this
> feature MLX4_DEV_CAP_FLAG2_SYS_EQS then during this path the function alloc
> icm is called twice without freeing the structures from the first time.
> 
> Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Applied.
