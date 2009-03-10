From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/25] [net] BUG to BUG_ON changes
Date: Tue, 10 Mar 2009 04:24:17 -0700 (PDT)
Message-ID: <20090310.042417.242564481.davem@davemloft.net>
References: <1236661850-8237-3-git-send-email-stoyboyker@gmail.com>
	<1236661850-8237-4-git-send-email-stoyboyker@gmail.com>
	<20090310102355.GB2248@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stoyboyker@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56859
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755475AbZCJLYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 07:24:31 -0400
In-Reply-To: <20090310102355.GB2248@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 10 Mar 2009 13:23:55 +0300

> On Tue, Mar 10, 2009 at 12:10:28AM -0500, Stoyan Gaydarov wrote:
> > --- a/drivers/net/pppol2tp.c
> > +++ b/drivers/net/pppol2tp.c
> > @@ -1222,8 +1222,7 @@ static void pppol2tp_tunnel_closeall(struct pppol2tp_tunnel *tunnel)
> >  	struct pppol2tp_session *session;
> >  	struct sock *sk;
> >  
> > -	if (tunnel == NULL)
> > -		BUG();
> > +	BUG_ON(tunnel == NULL);
> 
> NAK, should be deleted, and kernel will oops anyway.

I think in situations such as this, where someone is trying to rid the
tree of an interface (where an exactly equivalent alternative
expression exists) so it can be deleted, it is absolutely unreasonable
to ask them to make non-trivial transformations like you are
requesting on top of what can already be a quite daunting task.

Please rescind your NACK, thanks.

This is the kind of NACK which makes me absolutely furious when I try
to contribute to projects other than the kernel.  So please don't make
the kernel suck as much as those projects do.  It's a deterrant to
contributors.
