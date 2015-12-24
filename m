From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qlcnic: fix a loop exit condition better
Date: Thu, 24 Dec 2015 11:02:10 -0500 (EST)
Message-ID: <20151224.110210.773566977565532234.davem@davemloft.net>
References: <20151215201734.GJ5177@mwanda>
	<20151224092122.GG29642@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	manish.chopra@qlogic.com, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169AbbLXQCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 11:02:14 -0500
In-Reply-To: <20151224092122.GG29642@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Dec 2015 12:21:22 +0300

> In the original code, if we succeeded on the last iteration through the
> loop then we still returned failure.
> 
> Fixes: 389e4e04ad2d ('qlcnic: fix a timeout loop')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
