From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: remove macro-local declarations
Date: Sat, 07 Nov 2015 13:18:34 -0500 (EST)
Message-ID: <20151107.131834.2152455608881468661.davem@davemloft.net>
References: <alpine.DEB.2.02.1511052107501.2065@localhost6.localdomain6>
	<20151105.151320.1646543343654766675.davem@davemloft.net>
	<alpine.DEB.2.10.1511061142440.2378@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lkp@intel.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbbKGSSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 13:18:37 -0500
In-Reply-To: <alpine.DEB.2.10.1511061142440.2378@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Fri, 6 Nov 2015 11:57:34 +0100 (CET)

>> > Would it be preferable to remove the macro entirely and inline the for
>> > loop header?
>>
>> Could you show me an example of how this would look exactly?
> 
> One possible solution is below.  I moved the initialization of the nh
> pointer inside the loop to reduce the size of the loop header.  One could
> also inline fi->fib_nh[nhsel] where it occurs, but it seemed that that
> would make quite long expressions.

Personally I like the explicit named iterator.  It is descriptive and
tells that we are walking over all of the nexthops for a route.
