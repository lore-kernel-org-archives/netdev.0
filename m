From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibm_newemac: Increase MDIO timeouts
Date: Fri, 25 Apr 2008 18:58:42 -0500
Message-ID: <20080425185842.7ab463e7@zod.rchland.ibm.com>
References: <20080423051832.63BF7DDF65@ozlabs.org>
	<20080425165703.864e63bd.billfink@mindspring.com>
	<1209162158.5420.35.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	super.firetwister@googlemail.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:51592 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbYDZAEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 20:04:41 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3Q04b6S028317
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 20:04:37 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3Q04aQd233200
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 20:04:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3Q04PbR024504
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 20:04:26 -0400
In-Reply-To: <1209162158.5420.35.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Apr 2008 08:22:38 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Fri, 2008-04-25 at 16:57 -0400, Bill Fink wrote:
> > On Wed, 23 Apr 2008, Benjamin Herrenschmidt wrote:
> > 
> > > This patch doubles the MDIO timeouts in EMAC as there are field
> > > cases where they are two short to communicate with some PHYs.
> > 
> > I guess them being "two short" is why they needed to be doubled.  :-)
> 
> Well, in that case, it makes sense, it's still pretty short and better
> safe than sorry. On day I may look at actually measuring PHYs and see if
> it's worth trying to do sleeping waits in there.

I think you missed Bill's joke.  Read your original email and spot the
typo, then read Bill's pun.

And stop emailing before you eat breakfast ;)

josh
