From: David Miller <davem@davemloft.net>
Subject: Re: [patch] irda: small read beyond end of array in debug code
Date: Wed, 27 Feb 2013 13:12:17 -0500 (EST)
Message-ID: <20130227.131217.1331086829065132895.davem@davemloft.net>
References: <20130227051502.GC22703@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932561Ab3B0SMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:12:18 -0500
In-Reply-To: <20130227051502.GC22703@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 27 Feb 2013 08:15:02 +0300

> charset comes from skb->data.  It's a number in the 0-255 range.
> If we have debugging turned on then this could cause a read beyond
> the end of the array.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
