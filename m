From: David Miller <davem@davemloft.net>
Subject: Re: [patch] dcbnl: unlock on an error path in dcbnl_cee_fill()
Date: Fri, 08 Jul 2011 09:02:40 -0700 (PDT)
Message-ID: <20110708.090240.1560541664509139277.davem@davemloft.net>
References: <20110708072724.GW18655@shale.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulikr@broadcom.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab1GHQCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 12:02:46 -0400
In-Reply-To: <20110708072724.GW18655@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 8 Jul 2011 10:27:24 +0300

> We need to release "dcb_lock" which we took on the previous line.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks!
