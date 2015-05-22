From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] cxgb4: Add support for loopback between
 VI of same port
Date: Fri, 22 May 2015 14:01:00 -0400 (EDT)
Message-ID: <20150522.140100.204940697669252730.davem@davemloft.net>
References: <4985EFDD773FCB459EF7915D2A3621ADBD9FE5@nice.asicdesigners.com>
	<20150521.153029.774385014187583893.davem@davemloft.net>
	<4985EFDD773FCB459EF7915D2A3621ADBDA809@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	nirranjan@chelsio.com
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945932AbbEVSBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:01:05 -0400
In-Reply-To: <4985EFDD773FCB459EF7915D2A3621ADBDA809@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Fri, 22 May 2015 16:49:03 +0000

>   Oh I definitely understand that and agree.  Unfortunately I've
> inherited a driver architecture that makes that ... "difficult"
> for many operations ...  And I have an internal bug filed
> against me to fix those particular issues.
> 
>   However, that doesn't answer at least one of my questions
> which was how do I pass information into the driver _before_
> it does the device probe?

I did answer the question, I said that if you fix the real actual
core problem then you won't have this need to begin with.

I thought I made that perfectly clear.

I really am not going to entertain arguments of the form "it's
too hard to implement this correctly so I'm going to try
and slam a module parameter into the driver to fix things".
