From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tulip: cleanup by using ARRAY_SIZE()
Date: Thu, 23 Jan 2014 13:29:03 -0800 (PST)
Message-ID: <20140123.132903.1418930141853313681.davem@davemloft.net>
References: <20140123082637.GC28688@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbaAWV3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:29:03 -0500
In-Reply-To: <20140123082637.GC28688@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 23 Jan 2014 11:26:37 +0300

> In this situation then ARRAY_SIZE() and sizeof() are the same, but we're
> really dealing with array indexes and not byte offsets so ARRAY_SIZE()
> is cleaner.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
