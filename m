From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: pass pci_device_id.driver_data
 to __mlx4_init_one during reset
Date: Wed, 26 Mar 2014 16:54:52 -0400 (EDT)
Message-ID: <20140326.165452.947626238773658226.davem@davemloft.net>
References: <1395756620-7719-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbaCZUyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 16:54:54 -0400
In-Reply-To: <1395756620-7719-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Tue, 25 Mar 2014 22:10:19 +0800

> +	const struct pci_device_id*  id;

This is not the correct way to format a pointer declaration, it's

	TYPE *VAR;

not

	TYPE* VAR;
