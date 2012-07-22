From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnl: Add #ifdef CONFIG_RPS around num_rx_queues
 reference
Date: Sun, 22 Jul 2012 12:28:25 -0700 (PDT)
Message-ID: <20120722.122825.10630724642009598.davem@davemloft.net>
References: <1342827313-2827-1-git-send-email-mgreer@animalcreek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: mgreer@animalcreek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2GVT20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:28:26 -0400
In-Reply-To: <1342827313-2827-1-git-send-email-mgreer@animalcreek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mark A. Greer" <mgreer@animalcreek.com>
Date: Fri, 20 Jul 2012 16:35:13 -0700

> From: "Mark A. Greer" <mgreer@animalcreek.com>
> 
> Commit 76ff5cc91935c51fcf1a6a99ffa28b97a6e7a884
> (rtnl: allow to specify number of rx and tx queues
> on device creation) added a reference to the net_device
> structure's 'num_rx_queues' member in
> 
> 	net/core/rtnetlink.c:rtnl_fill_ifinfo()
> 
> However, the definition for 'num_rx_queues' is surrounded
> by an '#ifdef CONFIG_RPS' while the new reference to it is
> not.  This causes a compile error when CONFIG_RPS is not
> defined.
> 
> Fix the compile error by surrounding the new reference to
> 'num_rx_queues' by an '#ifdef CONFIG_RPS'.
> 
> CC: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Mark A. Greer <mgreer@animalcreek.com>

Applied, thanks Mark.
