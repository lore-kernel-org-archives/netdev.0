From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] net/mlx4: Fixes to mlx4_core driver.
Date: Fri, 07 Sep 2012 12:58:54 -0400 (EDT)
Message-ID: <20120907.125854.2234018619889706404.davem@davemloft.net>
References: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab2IGQ64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 12:58:56 -0400
In-Reply-To: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Date: Thu,  6 Sep 2012 11:50:47 +0300

> Add security check / enforcement for flow steering rules set for VMs:
> Since VFs may be mapped to VMs which aren't trusted entities, flow
> steering rules attached through the wrapper on behalf of VFs must be
> checked to make sure that their L2 specification relate to MAC address
> assigned to that VF, and add L2 specification if its missing.
> 
> Fixing bad handling of command failures, can lead to crash.
> 
> Fixing wrong promiscuous mode entries management.

All applied, thanks.
