From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Mon, 11 Jan 2010 21:31:28 +0100
Message-ID: <20100111203128.GA3139@del.dom.local>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
 <4B4A729E.9060805@gmail.com>
 <20100111132647.GA11193@ff.dom.local>
 <201001112032.24243.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Berck E. Nash" <flyboy@gmail.com>, netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:50640 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab0AKUbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 15:31:34 -0500
Received: by fxm25 with SMTP id 25so16589fxm.21
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 12:31:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <201001112032.24243.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2010 at 08:32:24PM +0100, Rafael J. Wysocki wrote:
> On Monday 11 January 2010, Jarek Poplawski wrote:
> > On Sun, Jan 10, 2010 at 05:36:46PM -0700, Berck E. Nash wrote:
> > > Rafael J. Wysocki wrote:
> > > > This message has been generated automatically as a part of a report
> > > > of recent regressions.
> > > > 
> > > > The following bug entry is on the current list of known regressions
> > > > from 2.6.32.  Please verify if it still should be listed and let me know
> > > > (either way).
> > 
> > BTW, I don't know why Berck didn't experience such a panic before
> > 2.6.32, but seems not a regression to me. There might be new/more sky2
> > TX timeouts which trigger this panic and would make a real regression.
> 
> Even if the code has always been broken, but it's only become visible after
> 2.6.32, that still counts as a regression IMO, because now the users are
> affected who weren't before.

Right, but:
1) someone with a similar but older problem might be mislead a fix is
   not for them;
2) someone with exactly this one problem (i.e. Berck ;-) might be
   mislead "no oops" is enough, while their linux might be still worse
   than before. (So I intended Berck to re-consider or even re-check
   this problem wrt. 2.6.31, and maybe even reporting another
   regression.)

Jarek P.
