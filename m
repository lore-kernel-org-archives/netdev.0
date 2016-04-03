From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Subject: Re: [PATCH v2] rds: rds-stress show all zeros after few minutes
Date: Sun, 3 Apr 2016 15:29:52 +0300
Message-ID: <20160403122951.GA14675@shamir-linux.uk.oracle.com>
References: <1459405762-29778-1-git-send-email-shamir.rabinovitch@oracle.com>
 <20160331.160246.2179579552166806534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27334 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbcDCM37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 08:29:59 -0400
Content-Disposition: inline
In-Reply-To: <20160331.160246.2179579552166806534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 04:02:46PM -0400, David Miller wrote:
> From: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> Date: Thu, 31 Mar 2016 02:29:22 -0400
> 
> > Issue can be seen on platforms that use 8K and above page size
> > while rds fragment size is 4K. On those platforms single page is
> > shared between 2 or more rds fragments. Each fragment has its own
> > offset and rds congestion map code need to take this offset to account.
> > Not taking this offset to account lead to reading the data fragment
> > as congestion map fragment and hang of the rds transmit due to far
> > congestion map corruption.
> > 
> > Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> > 
> > Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
> > Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
> > Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> > Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>
> 
> This doesn't apply cleanly to my current tree, please respin.

Sorry for the trouble.

Re-sent the patch based on net-next master.
Broke the patch according to comments from Santosh Shilimkar.

BR, Shamir
