From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/3] Mellanox EN driver fixes 2014-06-23
Date: Wed, 02 Jul 2014 18:29:48 -0700 (PDT)
Message-ID: <20140702.182948.1984091731017581414.davem@davemloft.net>
References: <1404032097-5132-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaGCB3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:29:49 -0400
In-Reply-To: <1404032097-5132-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun, 29 Jun 2014 11:54:54 +0300

> Below are some fixes to patches submitted to 3.16.
> 
> First patch is according to discussions with Ben [1] and Thomas [2] - to do not
> use affinity notifier, since it breaks RFS. Instead detect changes in IRQ
> affinity map, by checking if current CPU is set in affinity map on NAPI poll.
> The two other patches fix some bugs introduced in commit [3].
> 
> Patches were applied and tested over commit dba6311: ('powerpc: bpf: Fix the
> broken LD_VLAN_TAG_PRESENT test')

Series applied, thanks.
