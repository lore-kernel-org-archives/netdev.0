From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: remove workqueue when driver registration fails
Date: Mon, 16 Sep 2013 00:53:24 -0400 (EDT)
Message-ID: <20130916.005324.187580687457026092.davem@davemloft.net>
References: <1379253180-10292-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab3IPEx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 00:53:28 -0400
In-Reply-To: <1379253180-10292-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Sun, 15 Sep 2013 21:53:00 +0800

> When driver registration fails, we need to clean up the resources allocated
> before. cxgb4 missed to destroy the workqueue allocated at the very beginning.
> 
> This patch destroies the workqueue when registration fails.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Applied.
