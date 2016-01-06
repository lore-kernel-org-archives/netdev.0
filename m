From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/8] mlxsw: add offload support for
 vlan_filtering option
Date: Wed, 06 Jan 2016 14:43:04 -0500 (EST)
Message-ID: <20160106.144304.505880478517022892.davem@davemloft.net>
References: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbcAFTnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 14:43:07 -0500
In-Reply-To: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  6 Jan 2016 13:01:03 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Elad says:
> 
> This patch adds SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING port attribute.
> When a bridge is offloaded to hardware, the hardware can learn if the bridge is
> .1Q bridge (VLAN-aware) or not VLAN aware bridge.
> In order to toggle the mode a user can use sysfs:
> $ echo 1 > /sys/devices/virtual/net/br0/bridge/vlan_filtering
> or via iproute2:
> $ ip link set dev br0 type bridge vlan_filtering 1
> 
> ---
> v1->v2: small fix in patch #1

Series applied, thanks Jiri and Elad.
