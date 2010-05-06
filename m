From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] document initcwnd
Date: Wed, 5 May 2010 19:33:07 -0700
Message-ID: <20100505193307.42382590@nehalam>
References: <alpine.LNX.2.00.1005050210230.8544@d>
	<4BE171EC.20904@athenacr.com>
	<alpine.LNX.2.00.1005051239290.28957@d>
	<4BE1DB82.2030403@athenacr.com>
	<20100505150343.0c09c6ba@nehalam>
	<4BE21D64.4040600@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dormando <dormando@rydia.net>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>, shemminger@osdl.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49012 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439Ab0EFCdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 22:33:20 -0400
In-Reply-To: <4BE21D64.4040600@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 May 2010 21:37:40 -0400
Brian Bloniarz <bmb@athenacr.com> wrote:

> Stephen Hemminger wrote:
> > On Wed, 05 May 2010 16:56:34 -0400
> > Brian Bloniarz <bmb@athenacr.com> wrote:
> > 
> >> dormando wrote:
> >>>> This sounds like TCP slow start.
> >>>>
> >>>> http://en.wikipedia.org/wiki/Slow-start
> >>>>
> >>>> As far as tunables you might want to play with the initcwnd route
> >>>> flag (see "ip route help")
> >>> Ah, yes, initcwnd was it. I'm well aware of TCP Congestion control / slow
> >>> start / etc. However I couldn't find the damn tunable for it :)
> >> Documenting the flag in ip(8) might increase its visibility
> >> a little. I don't see it documented in the iproute2 git head,
> >> though it shows up on http://linux.die.net/man/8/ip somehow.
> >>
> >> Stephen, do you know why that is?
> > 
> > No one sent me an official patch to change it?
> 
> Mention initcwnd in ip(8). Text taken from doc/ip-cref.tex.
> 
> Signed-off-by: Brian Bloniarz <bmb@athenacr.com>

Ok, I will add it with an explicit caution about not doing this on public
networks.
