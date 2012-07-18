From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 1/9] IB/ipoib: Add support for clones /
 multiple childs on the same partition
Date: Wed, 18 Jul 2012 11:38:50 -0700 (PDT)
Message-ID: <20120718.113850.305478348143779010.davem@davemloft.net>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
	<1342609202-32427-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, shlomop@mellanox.com, erezsh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317Ab2GRSiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:38:51 -0400
In-Reply-To: <1342609202-32427-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 18 Jul 2012 13:59:54 +0300

> All sorts of childs are still created/deleted through sysfs, in a
> similar manner to the way legacy child interfaces are.

Network device instantiation of this type is the domain of
rtnl_link_ops rather than ugly sysfs interfaces.
