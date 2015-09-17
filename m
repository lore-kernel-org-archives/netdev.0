From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix vti use case with oif in dst lookups
Date: Thu, 17 Sep 2015 16:36:46 -0700 (PDT)
Message-ID: <20150917.163646.1426884857227848780.davem@davemloft.net>
References: <1442355050-9214-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbbIQXgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:36:47 -0400
In-Reply-To: <1442355050-9214-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 15 Sep 2015 15:10:50 -0700

> Steffen reported that the recent change to add oif to dst lookups breaks
> the VTI use case. The problem is that with the oif set in the flow struct
> the comparison to the nh_oif is triggered. Fix by splitting the
> FLOWI_FLAG_VRFSRC into 2 flags -- one that triggers the vrf device cache
> bypass (FLOWI_FLAG_VRFSRC) and another telling the lookup to not compare
> nh oif (FLOWI_FLAG_SKIP_NH_OIF).
> 
> Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
