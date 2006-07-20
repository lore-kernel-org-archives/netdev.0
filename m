From: Brent Cook <bcook@bpointsys.com>
Subject: Re: Alternate to Ixia's ANVL test harness for tcp compliance.
Date: Thu, 20 Jul 2006 16:47:14 -0500
Message-ID: <200607201647.15334.bcook@bpointsys.com>
References: <1153424967.8114.450.camel@piet2.bluelane.com> <1153427074.8114.466.camel@piet2.bluelane.com> <44BFF644.2020507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: piet@bluelane.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	piet at work <piet@work.piet.net>,
	Rajneesh Saini <rksaini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:1077 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1750753AbWGTVrV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 17:47:21 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44BFF644.2020507@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 20 July 2006 16:31, Jeff Garzik wrote:
> Piet Delaney wrote:
> > I wonder if Microsoft is providing the "big challenge" to porting the
> > same GUI to linux. The world really doesn't need yet another Java
> > language. Gosling is a Genius, I studied his X11 News Server enough
> > to know first hand. Microsoft lost in court with their violating the
> > Java standards and C sharp seems to be just another stratagy to their
> > bizarre attempt to world domination (Like the SCO mess).
>
> Runtime dynamic bytecode languages -- Java, Perl, Python, Ruby, ... --
> do seem to be all the rage.
>
> As DaveM noted, though, C# is fully supported under Linux.
>
> Or maybe they could go for Gtk+, which has successfully been used to
> maintain complex GUIs apps on both Windows and Linux.  GIMP is the most
> notable example, but use of Gtk+, GLib, and mingw has meant that you can
> build Linux-ish apps on Windows without nasty porting layers like Cygwin.
>
> 	Jeff
>

Base C# support is pretty good in Mono, but you still have to be quite careful 
when creating a cross-platform application with it. Microsoft's version 
implements a number of libraries that still are not quite as well implemented 
in Mono (if at all). The toolkit libraries (Windows Forms, to the latest 
stuff with Vista) are a bit of a moving target. Plus, the .Net platform still 
lets developers interact with COM objects and other Windows-only code.

Just because the GUI is C# does not mean that it does not have a number of 
Windows-only dependencies, unless it was implemented with portability 
in-mind.
