From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] [PATCH] net: sxgbe: Fix waring for double kfree()
Date: Fri, 16 Jan 2015 10:12:30 +0300
Message-ID: <20150116071229.GH5520@mwanda>
References: <1421286191-9550-1-git-send-email-kgene@kernel.org>
 <20150115.191416.1303150560556013280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kgene@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	bh74.an@samsung.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36547 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbAPHMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 02:12:41 -0500
Content-Disposition: inline
In-Reply-To: <20150115.191416.1303150560556013280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 07:14:16PM -0500, David Miller wrote:
> From: Kukjin Kim <kgene@kernel.org>
> Date: Thu, 15 Jan 2015 10:43:11 +0900
> 
> > From: Byungho An <bh74.an@samsung.com>
> > 
> > This patch fixes double kfree() calls at init_rx_ring() because
> > it causes static checker warning.
> > 
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Byungho An <bh74.an@samsung.com>
> > Signed-off-by: Kukjin Kim <kgene@kernel.org>
> 
> Applied.

It does silence the warning but it doesn't fix the bug.

Kukjin, let me know if you have any questions.  I can write the fix if
you need me to.

regards,
dan carpenter
