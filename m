From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netconsole: fix build when
 CONFIG_NETCONSOLE_DYNAMIC is turned on
Date: Tue, 21 Jun 2011 16:26:58 -0700 (PDT)
Message-ID: <20110621.162658.2225538921640361550.davem@davemloft.net>
References: <20110620212504.e639ad5c.randy.dunlap@oracle.com>
	<1308660309.3093.108.camel@localhost>
	<20110621110120.50c3b57d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	hilld@binarystorm.net
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756909Ab1FUX1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 19:27:34 -0400
In-Reply-To: <20110621110120.50c3b57d.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 21 Jun 2011 11:01:20 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> When NETCONSOLE_DYNAMIC=y and CONFIGFS_FS=m, there are build errors
> in netconsole:
> 
> drivers/built-in.o: In function `drop_netconsole_target':
> netconsole.c:(.text+0x1a100f): undefined reference to `config_item_put'
> drivers/built-in.o: In function `make_netconsole_target':
> netconsole.c:(.text+0x1a10b9): undefined reference to `config_item_init_type_name'
> drivers/built-in.o: In function `write_msg':
> netconsole.c:(.text+0x1a11a4): undefined reference to `config_item_get'
> netconsole.c:(.text+0x1a1211): undefined reference to `config_item_put'
> drivers/built-in.o: In function `netconsole_netdev_event':
> netconsole.c:(.text+0x1a12cc): undefined reference to `config_item_put'
> netconsole.c:(.text+0x1a12ec): undefined reference to `config_item_get'
> netconsole.c:(.text+0x1a1366): undefined reference to `config_item_put'
> drivers/built-in.o: In function `init_netconsole':
> netconsole.c:(.init.text+0x953a): undefined reference to `config_group_init'
> netconsole.c:(.init.text+0x9560): undefined reference to `configfs_register_subsystem'
> drivers/built-in.o: In function `dynamic_netconsole_exit':
> netconsole.c:(.exit.text+0x809): undefined reference to `configfs_unregister_subsystem'
> 
> so fix the NETCONSOLE_DYNAMIC depends clause to prevent this.
> Based on email suggestion from Ben Hutchings.  Thanks.
> 
> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=37992
> 
> Reported-by: David Hill <hilld@binarystorm.net>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
