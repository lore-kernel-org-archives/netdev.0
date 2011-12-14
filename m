From: David Miller <davem@davemloft.net>
Subject: Re: [patch] vlan: add rtnl_dereference() annotations
Date: Wed, 14 Dec 2011 02:47:19 -0500 (EST)
Message-ID: <20111214.024719.723458248077070552.davem@davemloft.net>
References: <20111214062943.GD7499@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, jpirko@redhat.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365Ab1LNHs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 02:48:29 -0500
In-Reply-To: <20111214062943.GD7499@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 14 Dec 2011 09:29:43 +0300

> The original code generates a Sparse warning:
> net/8021q/vlan_core.c:336:9:
> 	error: incompatible types in comparison expression (different address spaces)
> 
> It's ok to dereference __rcu pointers here because we are holding the
> RTNL lock.  I've added some calls to rtnl_dereference() to silence the
> warning.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
