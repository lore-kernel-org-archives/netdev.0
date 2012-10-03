From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bnx2x: use strlcpy() to copy a string
Date: Tue, 02 Oct 2012 22:41:42 -0400 (EDT)
Message-ID: <20121002.224142.1359092826405265517.davem@davemloft.net>
References: <20121002114746.GB1413@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab2JCCln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:41:43 -0400
In-Reply-To: <20121002114746.GB1413@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 2 Oct 2012 14:47:46 +0300

> DRV_MODULE_VERSION is smaller than the ->version buffer so the memcpy()
> copies 1 byte past the end of the string.  It's not super harmful, but
> it makes the static checkers complain.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
