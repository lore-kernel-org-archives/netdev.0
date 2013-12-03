From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: prevent BUG_ON triggered on congestion update to
 loopback
Date: Tue, 03 Dec 2013 11:55:06 -0500 (EST)
Message-ID: <20131203.115506.839802901968613934.davem@davemloft.net>
References: <1386027699-30513-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118Ab3LCQzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 11:55:08 -0500
In-Reply-To: <1386027699-30513-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Date: Mon,  2 Dec 2013 15:41:39 -0800

> After congestion update on a local connection, when rds_ib_xmit returns
> less bytes than that are there in the message, rds_send_xmit calls
> back rds_ib_xmit with an offset that causes BUG_ON(off & RDS_FRAG_SIZE)
> to trigger.
 ...
> Reported-by: Josh Hunt <joshhunt00@gmail.com>
> Tested-by: Honggang Li <honli@redhat.com>
> Acked-by: Bang Nguyen <bang.nguyen@oracle.com>
> Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

This looks great, applied and queued up for -stable, thanks!
