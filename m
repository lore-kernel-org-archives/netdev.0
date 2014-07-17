From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: cq->irq_desc wasn't set in legacy EQ's
Date: Wed, 16 Jul 2014 23:29:07 -0700 (PDT)
Message-ID: <20140716.232907.1529130147424838188.davem@davemloft.net>
References: <1405506830-12178-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaGQG3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:29:08 -0400
In-Reply-To: <1405506830-12178-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed, 16 Jul 2014 13:33:50 +0300

> Fix a regression introduced by commit 35f6f45 ("net/mlx4_en: Don't use
> irq_affinity_notifier to track changes in IRQ affinity map").
> When core is started in legacy EQ's (number of IRQ's < rx rings), cq->irq_desc
> was NULL.  This caused a kernel crash under heavy traffic - when having more
> than rx NAPI budget completions.
> Fixed to have it set for both EQ modes.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thank you.
