From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4: Remove shared_ports variable at
 mlx4_enable_msi_x
Date: Thu, 08 Oct 2015 05:20:52 -0700 (PDT)
Message-ID: <20151008.052052.2011670025950185856.davem@davemloft.net>
References: <1444235506-3099-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, matanb@mellanox.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756181AbbJHMFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 08:05:04 -0400
In-Reply-To: <1444235506-3099-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: clsoto@linux.vnet.ibm.com
Date: Wed,  7 Oct 2015 12:31:46 -0400

> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
> 
> If we get MAX_MSIX interrupts would like to have each receive ring
> with his own msix interrupt line. Do not need the shared_ports
> variable at mlx4_enable_msix
> 
> Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX')
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
> Acked-by: Matan Barak <matanb@mellanox.com>

Applied, thanks.
