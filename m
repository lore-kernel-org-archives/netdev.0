From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] netxen: write IP address to firmware when
 using bonding
Date: Wed, 13 Mar 2013 04:42:44 -0400 (EDT)
Message-ID: <20130313.044244.2078533144108853623.davem@davemloft.net>
References: <1363092541-12391-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	agospoda@redhat.com, sony.chacko@qlogic.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011Ab3CMImd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 04:42:33 -0400
In-Reply-To: <1363092541-12391-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue, 12 Mar 2013 13:49:01 +0100

> This patch allows LRO aggregation on bonded devices that contain an
> NX3031 device. It also adds a for_each_netdev_in_bond_rcu(bond, slave)
> macro which executes for each slave that has bond as master.

The new logic looks like it will configure the IPs for bonding
but not for VLANs, is that intentional?
