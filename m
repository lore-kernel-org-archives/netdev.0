From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Mellanox driver update Jul-08-2014
Date: Tue, 08 Jul 2014 19:59:16 -0700 (PDT)
Message-ID: <20140708.195916.1270230799804802543.davem@davemloft.net>
References: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbaGIC7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 22:59:18 -0400
In-Reply-To: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue,  8 Jul 2014 11:25:18 +0300

> This patch set introduce some small bug fixes.
> Most of the patches are small fixes to cornet case bugs.
> The patch by Noa ("Fix mac_hash database inconsistency") was sent in the past
> [1] and was droped because a fix to the bonding code was supposed to make it
> unnecessary. After a second look on the patch, it is still needed even
> after the direct access to dev_addr by the bonding will be fixed.
> 
> Patches were applied and tested over commit bd4578b
> ("drivers/net/hyperv/netvsc.c: remove unnecessary null test before kfree")
> 
> [1] - http://permalink.gmane.org/gmane.linux.network/315900

Series applied, thank you.

Signed-off-by: David S. Miller <davem@davemloft.net>
