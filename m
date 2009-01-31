From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] sfc: SFT9001: Enable robust link training
Date: Fri, 30 Jan 2009 16:02:27 -0800 (PST)
Message-ID: <20090130.160227.02430869.davem@davemloft.net>
References: <20090130034810.GC15266@solarflare.com>
	<20090130.140904.37637243.davem@davemloft.net>
	<1233360255.2799.17.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49311
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751601AbZAaAC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 19:02:29 -0500
In-Reply-To: <1233360255.2799.17.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 31 Jan 2009 00:04:15 +0000

> On Fri, 2009-01-30 at 14:09 -0800, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Fri, 30 Jan 2009 03:48:10 +0000
> > 
> > > From: Steve Hodgson <shodgson@solarflare.com>
> > > 
> > > Enable a firmware option that appears to be necessary for reliable
> > > operation.
> > > 
> > > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > 
> > I applied all of these patches but:
> > 
> > 1) When you get changes written by other people, such as
> >    Steve Hodgson here and in the next few patches, you need
> >    to get Signed-off-by lines from them too.
> 
> I have been attributing changes to my colleagues for some time and never
> heard this.  In any case the copyright lies with my employer and I am
> authorised to release these changes; isn't that what my initial sign-
> off means?

Sure, but it is even more meaningful if the person who actually
wrote the changes signs off on it too.

> > 2) Outside of the merge window I do not want to see totally
> >    irrelevant stuff like PHY loopback fixes.
> > 
> >    Those kinds of fixes are totally inappropriate at this time.
> 
> Are you saying that a spurious self-test failure is not a serious bug?

Normal users will not run the self-test giblet, and it has
not been reported as a 2.6.29 regression on lkml.
