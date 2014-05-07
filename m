From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Bug fixes.
Date: Wed, 07 May 2014 16:53:50 -0400 (EDT)
Message-ID: <20140507.165350.1864319940235696326.davem@davemloft.net>
References: <1399362409-17039-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaEGUxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 16:53:52 -0400
In-Reply-To: <1399362409-17039-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Tue, 6 May 2014 03:46:47 -0400

> This patch series contain following bug fixes.
> 
> * Fix panic where driver was accessing un-initialized crb_intr_mask
>   in non Multi-Tx queue mode while dumping TX queue.
> * Do not set netdev->real_num_tx_queues directly from driver instead
>   use kernel defined netif_set_real_num_tx_queues() API. Also notify
>   stack about change in number of Rx queues. 
>  
> Please apply this series to net.

Series applied, thanks Rajesh.
