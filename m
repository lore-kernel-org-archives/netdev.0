From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Wed, 28 Sep 2011 15:03:22 -0500
Message-ID: <4E837D8A.4080807@opengridcomputing.com>
References: <20110913194101.7497.65515.stgit@build.ogc.int> <20110927.013247.336618301904552114.davem@davemloft.net> <4E82075B.9000003@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jonathan Lallinger <jonathan@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:34277 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753882Ab1I1UDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 16:03:35 -0400
In-Reply-To: <4E82075B.9000003@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/27/2011 12:26 PM, Jonathan Lallinger wrote:
> Hello David,
>
> I am ashamed I made the same mistake twice. This happened because I had two git trees (I made a second one when 
> kernel.org went down based off the github remote). I fixed, built, and ran several tests on the patch, and then sent 
> the wrong patch from an old git tree (which was never build tested).
>
> I can assure you I have a working patch, and it has been tested by the QA group at Chelsio and it builds/runs but 
> there are still additional bugs in rds. So once I resolve those I will resend the correct patch with some additional 
> fixes.

Hey Jonathan,

I think you should get this patch resubmitted as-is (the correct patch though ;).  If we hit other issues in testing, 
then we can submit more patches.  The problems Chelsio is seeing may be backport issues and not upstream bugs.


Steve.
