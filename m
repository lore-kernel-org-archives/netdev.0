From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] phy: marvell: Fix 88E1510 initialization
Date: Thu, 25 Feb 2016 16:08:56 -0500 (EST)
Message-ID: <20160225.160856.1184683053443722763.davem@davemloft.net>
References: <1456255018-9632-1-git-send-email-clemens.gruber@pqgruber.com>
	<1456255018-9632-2-git-send-email-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clemens.gruber@pqgruber.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbcBYVJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:09:01 -0500
In-Reply-To: <1456255018-9632-2-git-send-email-clemens.gruber@pqgruber.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Clemens Gruber <clemens.gruber@pqgruber.com>
Date: Tue, 23 Feb 2016 20:16:58 +0100

> A bug was introduced in the merge commit b633353115e3 ("Merge
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
> The generic marvell_config_init (and therefore marvell_of_reg_init) is
> not called anymore for the Marvell 88E1510 (in net-next).
> 
> This patch calls marvell_config_init and moves the specific init
> function for the 88E1510 below the marvell_config_init function to avoid
> adding a function predeclaration.
> 
> Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>

Applied, thanks for noticing and fixing this merge error!
