From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] ibm_newemac: Introduce mal_has_feature
Date: Thu, 4 Sep 2008 23:37:24 -0400
Message-ID: <20080904233724.1115dd54@zod.rchland.ibm.com>
References: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com>
	<20080904150205.GC2479@yoda.jdub.homelinux.org>
	<1220584763.4879.97.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:41232 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbYIEDhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:37:33 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m853bW5b024086
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 23:37:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m853bWY2206614
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 23:37:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m853bWQ6030068
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 23:37:32 -0400
In-Reply-To: <1220584763.4879.97.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Sep 2008 13:19:23 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Thu, 2008-09-04 at 11:02 -0400, Josh Boyer wrote:
> > There are some PowerPC SoCs that do odd things with the MAL handling.  In
> > order to accommodate them, we need to introduce a feature mechanism that is
> > similar to the existing emac_has_feature function.
> > 
> > This adds a feature variable to the mal_instance structure, and adds a
> > mal_has_feature function with some feature definitions.  These are guarded
> > by Kconfig options that are selected by the affected platforms.
> > 
> > Signed-of-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> 
> You also add an actual feature (CLR_ICINSTAT). You should document that
> or move it to a separate patch.

I add two features.  And I so in the commit log, though I didn't
actually say what those do.  I can fix that up.

> 
> > +/* Features of various MAL implementations */
> > +
> > +/* Dummy feature bit so the enum works properly */
> > +#define MAL_FTR_DUMMY	0x00000001
> 
> Nah. Just stick an | 0 in the enum to make it happy.

OK.  I did that originally, but for some reason I wanted to avoid
having FTRS_ALWAYS and FTRS_POSSIBLE be equal if none of the Kconfig
options were set.  I can't remember why though.

josh
