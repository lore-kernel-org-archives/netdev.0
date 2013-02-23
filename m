From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: fix allocation of device tx_cq
Date: Sat, 23 Feb 2013 13:54:20 -0500 (EST)
Message-ID: <20130223.135420.332457089198054692.davem@davemloft.net>
References: <1361581082-5583-1-git-send-email-klebers@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org
To: klebers@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757322Ab3BWSyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 13:54:24 -0500
In-Reply-To: <1361581082-5583-1-git-send-email-klebers@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2013 21:58:02 -0300

> The memory to hold the network device tx_cq is not being allocated with
> the correct size in mlx4_en_init_netdev(). It should use MAX_TX_RINGS
> instead of MAX_RX_RINGS. This can cause problems if the number of tx
> rings being used is greater than MAX_RX_RINGS.
> 
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>

Applied.
