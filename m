From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] [70/2many] MAINTAINERS - ARPD SUPPORT
Date: Mon, 13 Aug 2007 17:35:22 +0100
Message-ID: <20070813173522.685dab9e@the-village.bc.nu>
References: <46bff8e8.HhTQ7TBPy1zkcNfh%joe@perches.com>
	<20070813114942.04a5483c@the-village.bc.nu>
	<1187019966.10249.75.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S948331AbXHMQ5F@vger.kernel.org>
In-Reply-To: <1187019966.10249.75.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Aug 2007 08:46:06 -0700
Joe Perches <joe@perches.com> wrote:

> On Mon, 2007-08-13 at 11:49 +0100, Alan Cox wrote:
> > > diff --git a/MAINTAINERS b/MAINTAINERS
> > > index 90c1b81..ac2226b 100644
> > > --- a/MAINTAINERS
> > > +++ b/MAINTAINERS
> > > @@ -697,6 +697,7 @@ ARPD SUPPORT
> > >  P:	Jonathan Layes
> > >  L:	netdev@vger.kernel.org
> > >  S:	Maintained
> > > +F:	net/ipv4/arp.c
> > 
> > NAK
> > 
> > arp.c is the netdev people, ARPD is a corner case bit of code within it,
> > something your patterns don't actually cope with
> 
> Suggestions?

I wouldn't add a pattern for this. Actually I think the entire thing is a
bad idea but thats another matter.
