From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sctp: check len in sctp_getsockopt_assoc_stats()
Date: Wed, 27 Feb 2013 15:45:44 -0500 (EST)
Message-ID: <20130227.154544.1758858137863453045.davem@davemloft.net>
References: <20130227204144.GA11300@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, michele@acksyn.org, sri@us.ibm.com,
	nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab3B0Upx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:45:53 -0500
In-Reply-To: <20130227204144.GA11300@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 27 Feb 2013 23:41:44 +0300

> This check is missing an upper bound.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This should go in 3.8 -stable as well.

There is a discussion and patch on netdev already.
