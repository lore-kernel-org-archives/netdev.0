From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn/kcapi: fix a small underflow
Date: Mon, 20 May 2013 13:38:34 -0700 (PDT)
Message-ID: <20130520.133834.1122105618365256928.davem@davemloft.net>
References: <20130519183636.GA25275@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835Ab3ETUif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:38:35 -0400
In-Reply-To: <20130519183636.GA25275@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sun, 19 May 2013 21:36:36 +0300

> In get_capi_ctr_by_nr() and get_capi_appl_by_nr() the parameter comes
> from skb->data.  The current code can underflow to one space before the
> start of the array.
> 
> The sanity check isn't needed in __get_capi_appl_by_nr() but I changed
> it to match the others.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
