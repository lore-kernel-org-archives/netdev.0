From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlxsw: spectrum: Fix compilation error when
 CLS_ACT isn't set
Date: Mon, 25 Jul 2016 17:57:46 -0700 (PDT)
Message-ID: <20160725.175746.852554746909121603.davem@davemloft.net>
References: <1469441553-6154-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719AbcGZA5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 20:57:47 -0400
In-Reply-To: <1469441553-6154-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Mon, 25 Jul 2016 13:12:33 +0300

> When CONFIG_NET_CLS_ACT isn't set 'struct tcf_exts' has no member named
> 'actions' and we therefore must not access it. Otherwise compilation
> fails.
> 
> Fix this by introducing a new macro similar to tc_no_actions(), which
> always returns 'false' if CONFIG_NET_CLS_ACT isn't set.
> 
> Fixes: 763b4b70afcd ("mlxsw: spectrum: Add support in matchall mirror TC offloading")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Applied.
