From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] enic: assign affinity hint to interrupts
Date: Mon, 02 Nov 2015 15:08:21 -0500 (EST)
Message-ID: <20151102.150821.2289802930601897972.davem@davemloft.net>
References: <1446204171-15080-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, ssujith@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbKBUJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:09:07 -0500
In-Reply-To: <1446204171-15080-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Fri, 30 Oct 2015 16:52:51 +0530

> The affinity hint is used by the user space daemon, irqbalancer, to
> indicate a preferred CPU mask for irqs. This patch sets the irq affinity
> hint to local numa core first, when exausted we try non-local numa cores.
> 
> Also set tx xps cpus mask bassed on affinity hint.
> 
> v2: remove the global affinity policy.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
