From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Subject: Re: [PATCH] rds: rds-stress show all zeros after few minutes
Date: Thu, 31 Mar 2016 17:20:48 +0300
Message-ID: <20160331142047.GA24193@shamir-linux.uk.oracle.com>
References: <1459385402-28449-1-git-send-email-shamir.rabinovitch@oracle.com>
 <56FD227F.502@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25488 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757365AbcCaOVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 10:21:03 -0400
Content-Disposition: inline
In-Reply-To: <56FD227F.502@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 04:13:35PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 3/31/2016 3:50 AM, shamir rabinovitch wrote:
> 
> >Issue can be seen on platforms that use 8K and above page size
> >while rds fragment size is 4K. On those platforms single page is
> >shared between 2 or more rds fragments. Each fragment has it's own
> 
>    Its.

Fixed in next version. 
Thanks.

> 
> >offeset and rds cong map code need to take this offset to account.
> 
>    Offset. What is "cong", congestion?

'Offset' is in middle of the sentence so it is OK as-is. 
Cong is short hand of congestion.
It will be replaces 
with the full word in next version.

> 
> >Not taking this offset to account lead to reading the data fragment
> >as congestion map fragment and hang of the rds transmit due to far
> >cong map corruption.
> >
> >Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
> >Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
> >Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> >Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>
> 
>    These should be after your sign-off, not before.

Thanks for the comment.
Will be fixed in next version.

> 
> >Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> [...]
> 
> MBR, Sergei
> 

Thanks for the review.
BR, Shamir
