From: David Miller <davem@davemloft.net>
Subject: Re: Section conflict compile failures in net
Date: Tue, 31 May 2011 19:25:14 -0700 (PDT)
Message-ID: <20110531.192514.33793304.davem@davemloft.net>
References: <1306445993.4048.58.camel@mulgrave.site>
	<20110531.154531.493226762.davem@davemloft.net>
	<1306892570.11897.35.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: James.Bottomley@HansenPartnership.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758580Ab1FACZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 22:25:19 -0400
In-Reply-To: <1306892570.11897.35.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 01 Jun 2011 10:42:50 +0900

> It's really, as has been said, a compiler problem: the compiler is
> confused about the read only sections.  However, 4.2 is a pretty common
> compiler (especially for non-x86), so if the compiler can't do the read
> only section tracking, just not using the __devinitconst designation
> globally seems to be the best thing, just change it to __devinitdata
> instead.

I think I'm just going to do a full revert then.

You guys work out how to arrive at a solution that solves the problem
he was originally trying to solve, yet doesn't break this gcc-4.2
case.

Thanks.
