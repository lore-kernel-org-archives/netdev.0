From: David Miller <davem@davemloft.net>
Subject: Re: [patch -resend] 9p: fix min_t() casting in p9pdu_vwritef()
Date: Wed, 27 Jun 2012 15:26:39 -0700 (PDT)
Message-ID: <20120627.152639.2113059689824053563.davem@davemloft.net>
References: <20120627085800.GA3007@mwanda>
	<20120627090141.GF31212@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ericvh@gmail.com, aneesh.kumar@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758060Ab2F0W0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:26:40 -0400
In-Reply-To: <20120627090141.GF31212@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 27 Jun 2012 12:01:41 +0300

> I don't think we're actually likely to hit this limit but if we do
> then the comparison should be done as size_t.  The original code
> is equivalent to:
>         len = strlen(sptr) % USHRT_MAX;
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
