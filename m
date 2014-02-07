From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tg3: cleanup an error path in tg3_phy_reset_5703_4_5()
Date: Thu, 06 Feb 2014 20:06:31 -0800 (PST)
Message-ID: <20140206.200631.1329672470949197117.davem@davemloft.net>
References: <20140205132920.GE800@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nsujir@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaBGEGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 23:06:32 -0500
In-Reply-To: <20140205132920.GE800@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 5 Feb 2014 16:29:21 +0300

> In the original code, if tg3_readphy() fails then it does an unnecessary
> check to verify "err" is still zero and then returns -EBUSY.
> 
> My static checker complains about the unnecessary "if (!err)" check and
> anyway it is better to propagate the -EBUSY error code from
> tg3_readphy() instead of hard coding it here.  And really the original
> code is confusing to look at.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
