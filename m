From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] switchdev: fix: erasing too much of
 vlan obj when handling multiple vlan specs
Date: Fri, 30 Oct 2015 20:23:58 +0900 (KST)
Message-ID: <20151030.202358.1386130918927885290.davem@davemloft.net>
References: <1446099451-62999-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759349AbbJ3LYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 07:24:06 -0400
In-Reply-To: <1446099451-62999-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 28 Oct 2015 23:17:30 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> When adding vlans with multiple IFLA_BRIDGE_VLAN_INFO attrs set in AFSPEC,
> we would wipe the vlan obj struct after the first IFLA_BRIDGE_VLAN_INFO.
> Fix this by only clearing what's necessary on each IFLA_BRIDGE_VLAN_INFO
> iteration.
> 
> Fixes: 9e8f4a54 ("switchdev: push object ID back to object structure")
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied.
