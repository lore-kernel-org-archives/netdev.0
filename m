From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix bug in Tx completion path
Date: Fri, 03 Jan 2014 20:44:22 -0500 (EST)
Message-ID: <20140103.204422.1125514975645141653.davem@davemloft.net>
References: <1388730868-19796-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com, shahed.shaikh@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbaADBoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:44:23 -0500
In-Reply-To: <1388730868-19796-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Fri, 3 Jan 2014 01:34:28 -0500

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> o Driver is using common tx_clean_lock for all Tx queues. This patch
>   adds per queue tx_clean_lock.
> o Driver is not updating sw_consumer while processing Tx completion
>   when interface is going down. Fixed in this patch.
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied, thanks.
