From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Mon, 11 Jan 2010 22:47:58 +0100
Message-ID: <20100111214758.GB3139@del.dom.local>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
 <4B4A729E.9060805@gmail.com>
 <20100111132647.GA11193@ff.dom.local>
 <201001112032.24243.rjw@sisk.pl>
 <20100111203128.GA3139@del.dom.local>
 <4B4B91F0.1090902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org
To: "Berck E. Nash" <flyboy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:33458 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab0AKVsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 16:48:03 -0500
Received: by fxm25 with SMTP id 25so74434fxm.21
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 13:48:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B4B91F0.1090902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2010 at 02:02:40PM -0700, Berck E. Nash wrote:
> Jarek Poplawski wrote:
> > 2) someone with exactly this one problem (i.e. Berck ;-) might be
> >    mislead "no oops" is enough, while their linux might be still worse
> >    than before. (So I intended Berck to re-consider or even re-check
> >    this problem wrt. 2.6.31, and maybe even reporting another
> >    regression.)
> 
> Well, the problem with this bug is how hard it is for me to reproduce.
> I'm willing to admit that just because I never got it before 2.6.32
> isn't proof that it wasn't there in 2.6.31.  But it's a regression
> somewhere along the line, since I've been using this hardware for over 3
> years now.  There were lots of bugs in the sky2 driver years ago, but
> for the last 2+ years or so, I haven't had any trouble at all until now.
> 
> The bug only shows up for me with bittorrent traffic.  I also use the
> same adapter to transfer backups over the network from several
> computers, and that doesn't trigger it...
> 
> I used 2.6.31 for however long it was the current stable, and I never
> got a crash with it.  After I got several crashes in 2.6.32, I reverted
> to 2.6.31 until Jarek sent this patch that seems to have fixed it.  I've
> never gotten it to crash in 2.6.31, so I'm pretty sure it's a 2.6.32
> regression, but I can't prove it.
> 
> I would love to do more testing, but since I can't reproduce the bug at
> will, I'm not really sure what to offer?

I mainly thought about looking at the logs during such bittorrent to
compare if there is any visible change in "sky2 eth0: disabling
interface"/"sky2 eth0: enabling interface" etc. frequency between
2.6.31 and 2.6.32.

Jarek P.
