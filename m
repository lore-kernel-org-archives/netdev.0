From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: validate_xmit_vlan() is static
Date: Mon, 06 Oct 2014 12:36:23 -0700
Message-ID: <1412624183.2916.35.camel@joe-AO725>
References: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412621042.2916.29.camel@joe-AO725> <20141006190728.GA2137@thin>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Dan Carpenter <error27@gmail.com>
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0157.hostedemail.com ([216.40.44.157]:58916 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750909AbaJFTg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:36:27 -0400
In-Reply-To: <20141006190728.GA2137@thin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 12:07 -0700, Josh Triplett wrote:
> On Mon, Oct 06, 2014 at 11:44:02AM -0700, Joe Perches wrote:
> > On Mon, 2014-10-06 at 11:26 -0700, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > Marking this as static allows compiler to inline it.
> > 
> > Found by inspection or another tool?
> > 
> > Wasn't there some tool to look for non-static functions
> > that are not called externally that could/should be
> > converted to static?
> 
> Several: sparse,

Doesn't find anything for this use case

> gcc -Wmissing-prototypes, and findstatic.pl.

Right, thanks, using "make W=1" adds -Wmissing-prototypes.
