From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 10:44:17 +0100
Message-ID: <20090616104417.657d6682@lxorguk.ukuu.org.uk>
References: <20090615.050449.144947903.davem@davemloft.net>
	<20090616091538.GA4184@elte.hu>
	<20090616.021955.243374916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:53695 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751485AbZFPJnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:43:15 -0400
In-Reply-To: <20090616.021955.243374916.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Jun 2009 02:19:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 16 Jun 2009 11:15:38 +0200
> 
> >  [<ffffffff810489e6>] __might_sleep+0xf6/0x120
> >  [<ffffffff81b3921d>] lock_sock_nested+0x3d/0x120
> >  [<ffffffff81c1a7d2>] x25_destroy_socket+0x22/0x180
> >  [<ffffffff81c1aa4e>] x25_destroy_timer+0xe/0x10
> >  [<ffffffff81060619>] run_timer_softirq+0x1d9/0x2e0
> >  [<ffffffff81060560>] ? run_timer_softirq+0x120/0x2e0
> 
> What on your system is openning x25 sockets?  Some stress/torture
> program that opens random sockets?
> 
> Or have you gotten into packet radio recently? :-)

packet radio is AX.25

X.25 is the CCITT wired network protocol over HDLC/LAP-B

