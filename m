From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: add support to show
 hw stats via ethtool get_regs
Date: Fri, 19 Jul 2013 17:32:02 -0700 (PDT)
Message-ID: <20130719.173202.1362261343675979678.davem@davemloft.net>
References: <1374242841-17141-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab3GTAcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 20:32:03 -0400
In-Reply-To: <1374242841-17141-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 19 Jul 2013 19:37:21 +0530

> Add support to show CPSW hardware statistics to user via ethtool get_regs
> ops so user can find if there were any error reported or the system is
> over loaded duing hagh data rate transfer.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

This is not the correct way to provide this functionality.  ->get_regs()
is for dumping the raw hardware registers to userspace for low level
debugging purposes, not for providing HW specific statistics.

The correct thing to do is provide an appropriate implementation of
the ->get_strings() and ->get_ethtool_stats() methods.
