From: Willy Tarreau <w@1wt.eu>
Subject: Re: [TCP bug] stuck distcc connections in latest -git
Date: Tue, 22 Jul 2008 23:12:56 +0200
Message-ID: <20080722211256.GB29189@1wt.eu>
References: <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721182318.GA20940@elte.hu> <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721184616.GA8442@elte.hu> <20080722112133.GA6575@elte.hu> <4885E482.5020502@davidnewall.com> <20080722135723.GA23077@elte.hu> <4885F496.3010305@davidnewall.com> <20080722153443.GB18757@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Newall <davidn@davidnewall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1906 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912AbYGVVON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:14:13 -0400
Content-Disposition: inline
In-Reply-To: <20080722153443.GB18757@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 05:34:43PM +0200, Ingo Molnar wrote:
> * David Newall <davidn@davidnewall.com> wrote:
> 
> > Ingo Molnar wrote:
> > > * David Newall <davidn@davidnewall.com> wrote:
> > >   
> > >> You really should start that capture, and on both client and server. 
> > >> You don't need to dump everything, only traffic to or from 
> > >> server:distcc.
> > >>     
> > >
> > > It's not feasible. That box did in excess of 200 GB of network traffic 
> > > in the past 7 hours alone.
> > 
> > You only need distcc traffic, and perhaps only after it's hung.  With 
> > 250k outstanding per socket, are you certain that no traffic was sent? 
> > Is it certain that one packet wasn't being sent each three minutes?  I 
> > suppose you're right and the stack really is stuck, but this is such 
> > an easy thing to check and eliminate that you should do so.  I 
> > suppose, too, that you should trace the server-side processes and 
> > confirm that they are waiting for socket input.  You should dump tcp 
> > (for the distcc port) next time the problem recurs and also check that 
> > the server processes are waiting for socket input.
> 
> ok, will do that if it happens again.

Ingo,

if it can help, I have a "capture" script which allows you to define
a size and will rotate captures within that size. That's what I'm
using to troubleshoot rarely occuring problems in datacenters, so
it's horrible but efficient :-)

You just have to stop it once the problem has happened again. Ping
me if you're interested (I'm lazy to start my laptop right just for
it now in fact).

Willy

