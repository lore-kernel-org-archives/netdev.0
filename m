From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netlabel: use GFP flags from caller instead of
 GFP_ATOMIC
Date: Thu, 22 Mar 2012 19:30:50 -0400 (EDT)
Message-ID: <20120322.193050.528451453813300397.davem@davemloft.net>
References: <20120322064101.GD7369@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab2CVXa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:30:56 -0400
In-Reply-To: <20120322064101.GD7369@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 22 Mar 2012 09:41:01 +0300

> This function takes a GFP flags as a parameter, but they are never used.
> We don't take a lock in this function so there is no reason to prefer
> GFP_ATOMIC over the caller's GFP flags.
> 
> There is only one caller, cipso_v4_map_cat_rng_ntoh(), and it passes
> GFP_ATOMIC as the GFP flags so this doesn't change how the code works.
> It's just a cleanup.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
