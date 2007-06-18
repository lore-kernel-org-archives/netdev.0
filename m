From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 02:35:20 -0700 (PDT)
Message-ID: <20070618.023520.102546505.davem@davemloft.net>
References: <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
	<20070618.021813.105401188.davem@davemloft.net>
	<E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751483AbXFRJfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 05:35:02 -0400
In-Reply-To: <E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 18 Jun 2007 11:29:52 +0200

> > > And is anyone working on a better patch?
> > 
> > I have no idea.
> > 
> > > Those patches aren't "bad" in the correctness sense.  So IMO any one
> > > of them is better, than having that bug in there.
> > 
> > You're adding a very serious performance regression, which is
> > about as bad as the bug itself.
> 
> No, correctness always trumps performance.

To a point.  There is no black and white in this world.

> Lost packets on an AF_UNIX socket are _unexceptable_, and this is
> definitely not a theoretical problem.

A lot of people will consider having all of their AF_UNIX sockets on
their 64 cpu system just stop when garbage collection runs to be
unacceptable as well.

Secondarily, this bug has been around for years and nobody noticed.
The world will not explode if this bug takes a few more days or
even a week to work out.  Let's do it right instead of ramming
arbitrary turds into the kernel.

> Do you want me to send the patch to Andrew instead?  His attitude
> towards bugfixes is rather better ;)

When I explain the ramifications of your patch to him, I'm pretty
sure he'll agree with me.
