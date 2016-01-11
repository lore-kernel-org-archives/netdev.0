From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fixes static checker warning in
 mps_tcam_show()
Date: Sun, 10 Jan 2016 22:42:34 -0500 (EST)
Message-ID: <20160110.224234.1175609809393289113.davem@davemloft.net>
References: <1452235885-28129-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757173AbcAKDmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:42:36 -0500
In-Reply-To: <1452235885-28129-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  8 Jan 2016 12:21:25 +0530

> The commit 115b56af88b5 ("cxgb4: Update mps_tcam output to include T6
> fields") from Dec 23, 2015, leads to the following static checker
> warning:
> 
>         drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c:1735
> mps_tcam_show()
>         warn: we tested 'lookup_type' before and it was 'true'
> 
> Fixing it.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
