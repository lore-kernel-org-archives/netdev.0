From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] cxgb3: fix up vpd strings for kstrto*()
Date: Fri, 19 Feb 2016 15:50:41 -0500 (EST)
Message-ID: <20160219.155041.2218228385135091410.davem@davemloft.net>
References: <20160218143946.0546CE09D8@smtp.ogc.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh@chelsio.com, hariprasad@chelsio.com
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993278AbcBSUun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:50:43 -0500
In-Reply-To: <20160218143946.0546CE09D8@smtp.ogc.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Thu, 18 Feb 2016 06:34:24 -0800

> The vpd strings are left justified, in a fixed length array, with possible
> trailing white space and no NUL.  So fix them up before calling kstrto*().
> 
> This is a recent regression which causes cxgb3 to fail to load.
> 
> Fixes:e72c932('cxgb3: Convert simple_strtoul to kstrtox')

Space after "Fixes: ", and after the commit ID too.  Double quotes to surround
the commit change log header line.

> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>

Applied, thanks.
