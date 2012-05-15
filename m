From: Mike Galbraith <mgalbraith@suse.de>
Subject: Re: [patch] Re: qlge driver corrupting kernel memory
Date: Tue, 15 May 2012 08:19:14 +0200
Message-ID: <1337062754.7273.25.camel@marge.simpson.net>
References: <1336474818.21924.94.camel@marge.simpson.net>
	 <20120508120748.GA3504@oc1711230544.ibm.com>
	 <1336736301.7361.144.camel@marge.simpson.net>
	 <1336903839.7390.13.camel@marge.simpson.net>
	 <1336904179.7390.16.camel@marge.simpson.net>
	 <1337009597.17437.1.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49481 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755214Ab2EOGTV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 02:19:21 -0400
In-Reply-To: <1337009597.17437.1.camel@marge.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-14 at 17:33 +0200, Mike Galbraith wrote: 
> (add CC)
> 
> On Sun, 2012-05-13 at 12:16 +0200, Mike Galbraith wrote: 
> > Erm, with a quilt refresh you get the compiling version :)
> > 
> > glge: Fix double pci_free_consistent() upon tx_ring->q allocation failure
> > 
> > Let ql_free_tx_resources() do it's job.  You are not helping.
> > 
> > Signed-off-by: Mike Galbraith <mgalbraith@suse.de>
> > ---
> >  drivers/net/qlge/qlge_main.c |   10 +++-------
> >  1 file changed, 3 insertions(+), 7 deletions(-)
> > 
> > --- a/drivers/net/qlge/qlge_main.c
> > +++ b/drivers/net/qlge/qlge_main.c

Sigh, never mind, this is patch from the wrong tree.  Maintainer will
fix buglet his way.

-Mike
