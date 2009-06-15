From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Any implementation of NETPOLL for bonding?
Date: Mon, 15 Jun 2009 19:09:07 -0400
Message-ID: <20090615230907.GA8515@gospo.rdu.redhat.com>
References: <1245101162.11148.210.camel@psmith-ubeta.netezza.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Paul Smith <paul@mad-scientist.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48549 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbZFOXKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 19:10:11 -0400
Content-Disposition: inline
In-Reply-To: <1245101162.11148.210.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 05:26:02PM -0400, Paul Smith wrote:
> I wanted to attach to my kernel with KGDBOE but failed because the
> bonding driver doesn't support NETPOLL, and the only network access to
> the system is over a bonded interface.
> 
> This is a big bummer for me :-).
> 

I did some work in the not-too-distant past on this and can probably
dig-up the patches and port them to the latest upstream.  Would you be
able to test a patch?

> Is there any possibility of NETPOLL being supported in the bonding
> driver?  I found a very old patch set from Jeff Moyer (circa 2005)
> adding NETPOLL support to the bonding driver but as far as I can
> determine it's not present in current kernels.
> 

It's a bit unclear to me why Jeff's patches were never accepted, but I
suspect if there were many that didn't like them before, they won't be
well received now, but it sure would be nice to use kgdb and use
netconsole on bonding interfaces, wouldn't it? :-)


