From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] mlxsw: core: remove an unnecessary condition
Date: Wed, 06 Jan 2016 15:08:06 -0500 (EST)
Message-ID: <20160106.150806.1402674809005659001.davem@davemloft.net>
References: <20160106095630.GB23185@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbcAFUIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:08:10 -0500
In-Reply-To: <20160106095630.GB23185@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 6 Jan 2016 12:56:30 +0300

> We checked "err" on the lines before so we know it's zero here.
> 
> These cause a static checker warning because checking known things can
> indicate a bug.  Maybe there is a missing assignment or we are checking
> the wrong variable.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
