From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [v2] net/fsl: fix a bug in xgmac_mdio
Date: Mon, 16 Mar 2015 16:28:02 -0400 (EDT)
Message-ID: <20150316.162802.1231341458598182028.davem@davemloft.net>
References: <1426503350-23181-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755271AbbCPU2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:28:05 -0400
In-Reply-To: <1426503350-23181-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Mon, 16 Mar 2015 18:55:50 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> There is a bug in xgmac_wait_until_done() which mdio_stat should be used
> instead of mdio_data when checking if busy bit is cleared.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
> changes for v2:
> splitted from http://patchwork.ozlabs.org/patch/450392/

Applied to net-next
