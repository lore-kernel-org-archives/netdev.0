From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion
 control RTT
Date: Fri, 21 Dec 2007 06:05:48 -0800 (PST)
Message-ID: <20071221.060548.97855627.davem@davemloft.net>
References: <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
	<20071221.031400.194877955.davem@davemloft.net>
	<20071221133106.GA7995@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Gavin.McCullagh@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58955
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755786AbXLUOFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:05:48 -0500
In-Reply-To: <20071221133106.GA7995@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Date: Fri, 21 Dec 2007 13:31:06 +0000

> On Fri, 21 Dec 2007, David Miller wrote:
> 
> > When Gavin respins the patch I'll look at in the context of submitting
> > it as a bug fix.  So Gavin please generate the patch against Linus's
> > vanilla GIT tree or net-2.6, your choise.
> 
> The existing patch was against Linus' linux-2.6.git from a few days ago so
> I've updated my tree and regenerated the patch (below).  Is that the right
> one?

Yep, it is.

> I need to re-read properly, but I think the same problem affects the
> microsecond values where TCP_CONG_RTT_STAMP is set (used by vegas, veno,
> yeah, illinois).  I might follow up with another patch which changes the
> behaviour where TCP_CONG_RTT_STAMP when I'm more sure of that.

Ok, let us know what you find.
