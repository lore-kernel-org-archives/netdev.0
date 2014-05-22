From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ieee802154: missing put_dev() on error
Date: Thu, 22 May 2014 15:55:08 -0400 (EDT)
Message-ID: <20140522.155508.1457164417698079548.davem@davemloft.net>
References: <20140522075306.GB4346@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaEVTzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:55:10 -0400
In-Reply-To: <20140522075306.GB4346@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 22 May 2014 10:53:06 +0300

> We should call put_dev() on the error path here.
> 
> Fixes: 3e9c156e2c21 ('ieee802154: add netlink interfaces for llsec')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
