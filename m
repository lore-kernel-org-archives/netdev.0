From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sctp: use the passed in gfp flags instead GFP_KERNEL
Date: Fri, 01 Mar 2013 16:00:05 -0500 (EST)
Message-ID: <20130301.160005.2165970105360874488.davem@davemloft.net>
References: <20130301052743.GD2669@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, sri@us.ibm.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab3CAVAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 16:00:07 -0500
In-Reply-To: <20130301052743.GD2669@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 1 Mar 2013 08:27:43 +0300

> This patch doesn't change how the code works because in the current
> kernel gfp is always GFP_KERNEL.  But gfp was obviously intended
> instead of GFP_KERNEL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
