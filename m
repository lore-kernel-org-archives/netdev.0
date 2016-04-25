From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Mon, 25 Apr 2016 15:26:11 -0400 (EDT)
Message-ID: <20160425.152611.583503438886577374.davem@davemloft.net>
References: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mmanning@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933325AbcDYT0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:26:14 -0400
In-Reply-To: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 21 Apr 2016 20:56:12 -0700

> Dave: I realize this goes against your preference to keep routes cached
>       on a down but this patch really emphasizes my point of all the
>       dark corners to be handled. 

I've learned my lesson, I never should have put the original patch in
to begin with.

And you're so sloppy here, you didn't even bother adding a Fixes: tag.

The patch at the root of all of this has terrible semantics, and it's
added tons of regressions.  All of which goes against our most basic
principles.

I've been patient enough, but I've now reverting everything, sorry.

It's unfortunate if you have things which depend upon this, but too
bad.  This change has been extremely disruptive for a lot of people,
including me.

You're going to have to work really hard to ever get me to consider
applying patches which do this again.
