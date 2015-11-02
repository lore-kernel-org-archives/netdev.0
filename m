From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: vlan: Use rcu_dereference instead of
 rtnl_dereference
Date: Mon, 02 Nov 2015 16:28:00 -0500 (EST)
Message-ID: <20151102.162800.2243209656295095377.davem@davemloft.net>
References: <1446395505-24841-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	nikolay@cumulusnetworks.com, jiri@mellanox.com, eladr@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbKBV2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:28:03 -0500
In-Reply-To: <1446395505-24841-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Sun, 1 Nov 2015 18:31:45 +0200

> br_should_learn() is protected by RCU and not by RTNL, so use correct
> flavor of nbp_vlan_group().
> 
> Fixes: 907b1e6e83ed ("bridge: vlan: use proper rcu for the vlgrp
> member")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
