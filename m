From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ehea: use consistent type
Date: Mon, 05 Jan 2009 16:19:26 -0800 (PST)
Message-ID: <20090105.161926.141190504.davem@davemloft.net>
References: <20081230.215101.228854586.davem@davemloft.net>
	<1230714541.15389.69.camel@pasglop>
	<20090106110511.43b0a87a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, tklein@de.ibm.com,
	netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linuxppc-dev@ozlabs.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750730AbZAFATZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 19:19:25 -0500
In-Reply-To: <20090106110511.43b0a87a.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 6 Jan 2009 11:05:11 +1100

> Hi Dave,
> 
> On Wed, 31 Dec 2008 20:09:01 +1100 Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> >
> > Well, in that case, this patch is actually correct without considering
> > the u64 change. The array is what lands in the registers of the pHyp
> > call, so strictly speaking, it's an array of unsigned long's (ie, 32-bit
> > on a 32-bit platform, 64-bit on a 64-bit platform), not an array of
> > u64's. This function being a wrapper on that pHyp call, it may as well
> > use the right type.
> 
> So, any response?

Please resubmit, I'll take another look :-)
