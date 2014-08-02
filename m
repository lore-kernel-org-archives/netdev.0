From: David Miller <davem@davemloft.net>
Subject: Re: [patch] dm9000: NULL dereferences on error in probe()
Date: Sat, 02 Aug 2014 15:28:38 -0700 (PDT)
Message-ID: <20140802.152838.10096907007372226.davem@davemloft.net>
References: <20140801082357.GC28869@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	andrew.ruder@elecsyscorp.com, nikita@compulab.co.il,
	grinberg@compulab.co.il, paul.gortmaker@windriver.com,
	jg1.han@samsung.com, ebiederm@xmission.com,
	michael.abbott@diamond.ac.uk, Baohua.Song@csr.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbaHBW2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:28:39 -0400
In-Reply-To: <20140801082357.GC28869@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 1 Aug 2014 11:23:57 +0300

> The dm9000_release_board() function is called with NULL ->data_req and
> ->addr_req pointers if dm9000_probe() fails.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks Dan.
