From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: prevent BUG_ON triggered on congestion update to
 loopback
Date: Sun, 01 Dec 2013 20:19:30 -0500 (EST)
Message-ID: <20131201.201930.2009545384899801860.davem@davemloft.net>
References: <1385167442-6997-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org, honli@redhat.com,
	joshhunt00@gmail.com, bang.nguyen@oracle.com
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab3LBBTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:19:32 -0500
In-Reply-To: <1385167442-6997-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Date: Mon, 25 Nov 2013 09:47:34 +0300

> From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> 
> After congestion update on a local connection, when rds_ib_xmit returns
> less bytes than that are there in the message, rds_send_xmit calls
> back rds_ib_xmit with an offset that causes BUG_ON(off & RDS_FRAG_SIZE)
> to trigger.
> 
> Reported-by: Josh Hunt <joshhunt00@gmail.com>
> Tested-by: Honggang Li <honli@redhat.com>
> Acked-by: Bang Nguyen <bang.nguyen@oracle.com>
> Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks Venkat, this is almost perfect.

Please adjust the commit message so that it contains all of the analysis
you posted before.  You can never include too much information, especially
for a fix for a bug that languished for such a long time like this one
did.  In particular you should mentioned the ppc bug fix that introduced
this regression, reference such commits in the following format:

	$SHA1_ID ("Commit message header text")

Thanks.
