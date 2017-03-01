From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: Fix error path in nbp_vlan_init
Date: Wed, 01 Mar 2017 14:56:20 -0800 (PST)
Message-ID: <20170301.145620.1575285327636466385.davem@davemloft.net>
References: <1488379845-38625-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        jiri@mellanox.com, roopa@cumulusnetworks.com
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753507AbdCAW4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 17:56:30 -0500
In-Reply-To: <1488379845-38625-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Wed,  1 Mar 2017 16:50:45 +0200

> Fix error path order in nbp_vlan_init, so if switchdev_port_attr_set
> call failes, the vlan_hash wouldn't be destroyed before inited.
> 
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Applied, thanks.
