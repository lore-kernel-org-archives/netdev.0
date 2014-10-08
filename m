From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2 v2 -next] cxgb4: potential shift wrapping bug
Date: Wed, 08 Oct 2014 16:08:44 -0400 (EDT)
Message-ID: <20141008.160844.421959946480563087.davem@davemloft.net>
References: <20141003.154629.555967384624529643.davem@davemloft.net>
	<20141008134317.GA12036@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbaJHUIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 16:08:46 -0400
In-Reply-To: <20141008134317.GA12036@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 8 Oct 2014 16:43:17 +0300

> "cntxt_id" is an unsigned int but "udb" is a u64 so there is a potential
> shift wrapping bug here.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
