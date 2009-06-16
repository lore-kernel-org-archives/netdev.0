From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 11:48:13 +0200
Message-ID: <20090616094813.GA1686@elte.hu>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.021955.243374916.davem@davemloft.net> <20090616104417.657d6682@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:40768 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbZFPJsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 05:48:21 -0400
Content-Disposition: inline
In-Reply-To: <20090616104417.657d6682@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> On Tue, 16 Jun 2009 02:19:55 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Tue, 16 Jun 2009 11:15:38 +0200
> > 
> > >  [<ffffffff810489e6>] __might_sleep+0xf6/0x120
> > >  [<ffffffff81b3921d>] lock_sock_nested+0x3d/0x120
> > >  [<ffffffff81c1a7d2>] x25_destroy_socket+0x22/0x180
> > >  [<ffffffff81c1aa4e>] x25_destroy_timer+0xe/0x10
> > >  [<ffffffff81060619>] run_timer_softirq+0x1d9/0x2e0
> > >  [<ffffffff81060560>] ? run_timer_softirq+0x120/0x2e0
> > 
> > What on your system is openning x25 sockets?  Some stress/torture
> > program that opens random sockets?
> > 
> > Or have you gotten into packet radio recently? :-)
> 
> packet radio is AX.25
> 
> X.25 is the CCITT wired network protocol over HDLC/LAP-B

I think David's larger point was that what looked to me like more 
widespread breakage was in fact limited to [a]x25, a comparatively 
rarely used (and rarely tested) corner of the kernel.

I turned them off and that solved the problems here. (and i suspect 
the real fix wont be far away either) Thanks everyone.

	Ingo
