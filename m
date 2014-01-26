From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix potential incorrect pointer dereference in
 xfrm_bundle_create
Date: Sat, 25 Jan 2014 18:05:34 -0800 (PST)
Message-ID: <20140125.180534.939675200515296620.davem@davemloft.net>
References: <1390675673-20682-1-git-send-email-horia.geanta@freescale.com>
	<20140125.110745.939440249416819926.davem@davemloft.net>
	<1390678378.20150.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horia.geanta@freescale.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbaAZCFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 21:05:37 -0500
In-Reply-To: <1390678378.20150.5.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 25 Jan 2014 11:32:58 -0800

> Yes, but perhaps the failure test be done before the
> assignment anyway.  There are more paths below the test
> where the value is not yet used.

And because we have no uses, there is no harm in the assignment.

> Perhaps something like this would be more readable.

That's a lot of useless churn if you ask me.

If we happen to be making other changes to this file, fine.
But there are much bigger fish to fry.
