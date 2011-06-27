From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net][bna] Fix call trace when interrupts are disabled
 while sleeping function kzalloc is called
Date: Mon, 27 Jun 2011 16:07:06 -0700 (PDT)
Message-ID: <20110627.160706.1453191829412045606.davem@davemloft.net>
References: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com, ddutt@brocadel.com,
	shyam_iyer@dell.com
To: shyam.iyer.t@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150Ab1F0XIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 19:08:12 -0400
In-Reply-To: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shyam Iyer <shyam.iyer.t@gmail.com>
Date: Mon, 27 Jun 2011 16:21:32 -0400

> The kzalloc sleeps and disabling interrupts(spin_lock_irqsave)
> causes oops like the one.

What if ->cfg_flags changes while you have dropped the lock?

If the lock doesn't protect those flags, what was it being
taken for in the first place?
