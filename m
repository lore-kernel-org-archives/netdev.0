From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Oct 2 (vxlan.c)
Date: Tue, 02 Oct 2012 14:36:27 -0400 (EDT)
Message-ID: <20121002.143627.1565408497543880722.davem@davemloft.net>
References: <20121002163229.d377074dc8f6c029428faeaa@canb.auug.org.au>
	<506B3317.5090006@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524Ab2JBSga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:36:30 -0400
In-Reply-To: <506B3317.5090006@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Tue, 02 Oct 2012 11:31:51 -0700

> on x86_64:
> 
> drivers/net/vxlan.c: In function 'vxlan_xmit':
> drivers/net/vxlan.c:725:2: error: implicit declaration of function 'ip_select_ident'
> 
> That function is only defined when CONFIG_INET is enabled,
> but it is disabled in this config.

This definitely depends upon INET, I'll add the Kconfig change
to net-next, thanks.
