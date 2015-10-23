From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] switchdev: fix: erasing too much of
 vlan obj when handling multiple vlan specs
Date: Fri, 23 Oct 2015 06:32:31 -0700 (PDT)
Message-ID: <20151023.063231.477008345409957977.davem@davemloft.net>
References: <1445570717-40780-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbJWNQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:16:02 -0400
In-Reply-To: <1445570717-40780-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 22 Oct 2015 20:25:15 -0700

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
