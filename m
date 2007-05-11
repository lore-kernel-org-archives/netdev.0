From: Simon Horman <horms@verge.net.au>
Subject: Re: Kconfig warnings on latest GIT
Date: Fri, 11 May 2007 10:25:31 +0900
Message-ID: <20070511012529.GC10715@verge.net.au>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <46434ED0.6030808@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?iso-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>,
	Kumar Gala <galak@kernel.crashing.org>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:45297 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759332AbXEKBZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 21:25:33 -0400
Content-Disposition: inline
In-Reply-To: <46434ED0.6030808@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 11:56:48AM -0500, Timur Tabi wrote:
> Simon Horman wrote:
> 
> >>So my question is: in which Kconfig do I define "UCC_FAST_TEMP" and 
> >>"UCC_SLOW_TEMP"?  At first I thought, just put it in drivers/Kconfig, but 
> >>that Kconfig does nothing but including other Kconfigs.  I believe that if I 
> >>submit a patch that adds "UCC_FAST_TEMP" and "UCC_SLOW_TEMP" to 
> >>drivers/Kconfig, it will be rejected.  Either that, or I'll spend six weeks 
> >>trying to persuade everyone that it's a good idea.
> >>
> >>Does anyone have any suggestions on how I can fix this?
> >That does seem like a reasonable suggestion, and one that
> >would probably work well with the other similar problems
> >that have been introduced sice 2.6.21.
> 
> Looks like the fix is simpler than I thought.  Instead of having
> 
> UCC_GETH
> 	select UCC_FAST
> 
> I need to do
> 
> UCC_FAST
> 	default y if UCC_GETH

I pondered something like that, but I couldn't get it quite right :(

> I'll have a patch that fixes this out later today.
> 
> I chose the first method because I wanted each individual UCC device
> driver to select UCC_FAST or UCC_SLOW as appropriate, so that I
> wouldn't have to update arch/powerpc/sysdev/qe_lib/Kconfig every time
> we add a new UCC driver.  Oh well.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

