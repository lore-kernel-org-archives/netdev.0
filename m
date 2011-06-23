From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] dcb: use nlmsg_free() instead of kfree()
Date: Thu, 23 Jun 2011 03:14:53 -0700 (PDT)
Message-ID: <20110623.031453.2027432684696519466.davem@davemloft.net>
References: <20110623055802.GN14591@shale.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shmulikr@broadcom.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759194Ab1FWKPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 06:15:00 -0400
In-Reply-To: <20110623055802.GN14591@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 23 Jun 2011 08:58:02 +0300

> These sk_buff structs were allocated with nlmsg_new() so they should
> be freed with nlmsg_free().
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
