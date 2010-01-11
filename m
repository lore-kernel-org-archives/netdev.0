From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Mon, 11 Jan 2010 21:50:17 +0100
Message-ID: <201001112150.17166.rjw@sisk.pl>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera> <201001112032.24243.rjw@sisk.pl> <20100111203128.GA3139@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Berck E. Nash" <flyboy@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:35232 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162Ab0AKUt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 15:49:59 -0500
In-Reply-To: <20100111203128.GA3139@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 January 2010, Jarek Poplawski wrote:
> On Mon, Jan 11, 2010 at 08:32:24PM +0100, Rafael J. Wysocki wrote:
> > On Monday 11 January 2010, Jarek Poplawski wrote:
> > > On Sun, Jan 10, 2010 at 05:36:46PM -0700, Berck E. Nash wrote:
> > > > Rafael J. Wysocki wrote:
> > > > > This message has been generated automatically as a part of a report
> > > > > of recent regressions.
> > > > > 
> > > > > The following bug entry is on the current list of known regressions
> > > > > from 2.6.32.  Please verify if it still should be listed and let me know
> > > > > (either way).
> > > 
> > > BTW, I don't know why Berck didn't experience such a panic before
> > > 2.6.32, but seems not a regression to me. There might be new/more sky2
> > > TX timeouts which trigger this panic and would make a real regression.
> > 
> > Even if the code has always been broken, but it's only become visible after
> > 2.6.32, that still counts as a regression IMO, because now the users are
> > affected who weren't before.
> 
> Right, but:
> 1) someone with a similar but older problem might be mislead a fix is
>    not for them;

Not if the fix changelog mentions the older kernels explicitly.

> 2) someone with exactly this one problem (i.e. Berck ;-) might be
>    mislead "no oops" is enough, while their linux might be still worse
>    than before. (So I intended Berck to re-consider or even re-check
>    this problem wrt. 2.6.31, and maybe even reporting another
>    regression.)

Yes, rechecking the problem with 2.6.31 would be useful.

Rafael
