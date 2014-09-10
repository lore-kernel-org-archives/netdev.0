From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: Fix wrong endianess access with QP context
 flags
Date: Wed, 10 Sep 2014 15:23:54 -0700 (PDT)
Message-ID: <20140910.152354.1516891361950612654.davem@davemloft.net>
References: <1410358511-13461-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbaIJWXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 18:23:55 -0400
In-Reply-To: <1410358511-13461-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 10 Sep 2014 17:15:11 +0300

> We wrongly tested QP context bits without BE conversion
> as was spotted by sparse...
> 
> drivers/infiniband/hw/mlx4/qp.c:1685:38: sparse: restricted __be32 degrades to integer
> 
> Fix that!
> 
> Fixes: d2fce8a ('mlx4: Set user-space raw Ethernet QPs to properly handle VXLAN traffic')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Series applied, thanks.
