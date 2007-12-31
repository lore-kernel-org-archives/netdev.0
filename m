From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ROSE][AX25] af_ax25: possible circular locking
Date: Sun, 30 Dec 2007 21:00:57 -0800 (PST)
Message-ID: <20071230.210057.139323937.davem@davemloft.net>
References: <20071228214857.GA3290@ami.dom.local>
	<20071229.191443.10947724.davem@davemloft.net>
	<20071230141323.GA3377@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f6bvp@free.fr, ralf@linux-mips.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60677
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750698AbXLaFA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 00:00:58 -0500
In-Reply-To: <20071230141323.GA3377@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 30 Dec 2007 15:13:23 +0100

> On Sat, Dec 29, 2007 at 07:14:43PM -0800, David Miller wrote:
> ...
> "again" loop should skip this entry next time: s->ax25_dev should
> be NULL, so not equal to ax25dev. (But of course there could be
> this unknown to me place, which changes this back in the meantime.)

Indeed you are right.

> > You'll thus need to resolve this locking conflict more properly.
> > I know it's hard, but your current fix is worse because it adds
> > a new known bug.
> 
> Sorry, it seems this will've to wait until Ralf finds some time,
> because I really can't give this more time, considering I never
> used nor have any plans to use this code, and this bug could
> suggest there is not so many interested in this, besides Bernard,
> either.

I'll try to look at this.
