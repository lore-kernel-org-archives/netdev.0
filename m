From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] rtnetlink: unlock on error path in netlink_dump()
Date: Thu, 16 Jun 2011 23:51:53 -0400 (EDT)
Message-ID: <20110616.235153.1947044865028978184.davem@davemloft.net>
References: <20110615131142.GE23739@shale.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, eric.dumazet@gmail.com, kaber@trash.net,
	chrisw@sous-sol.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732Ab1FQDxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:53:05 -0400
In-Reply-To: <20110615131142.GE23739@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 15 Jun 2011 16:11:42 +0300

> In c7ac8679bec939 "rtnetlink: Compute and store minimum ifinfo dump
> size", we moved the allocation under the lock so we need to unlock
> on error path.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks.
