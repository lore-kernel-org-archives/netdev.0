From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH net-next] net: validate_xmit_vlan() is static
Date: Mon, 6 Oct 2014 12:07:29 -0700
Message-ID: <20141006190728.GA2137@thin>
References: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <1412621042.2916.29.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Dan Carpenter <error27@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:40399 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbaJFTHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:07:41 -0400
Content-Disposition: inline
In-Reply-To: <1412621042.2916.29.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 06, 2014 at 11:44:02AM -0700, Joe Perches wrote:
> On Mon, 2014-10-06 at 11:26 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Marking this as static allows compiler to inline it.
> 
> Found by inspection or another tool?
> 
> Wasn't there some tool to look for non-static functions
> that are not called externally that could/should be
> converted to static?

Several: sparse, gcc -Wmissing-prototypes, and findstatic.pl.
