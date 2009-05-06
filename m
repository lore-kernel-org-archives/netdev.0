From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 22:30:04 +0300
Message-ID: <200905062230.04594.denys@visp.net.lb>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0105A8.3060707@cosmosbay.com> <1241635518.13702.37.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38645 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbZEFTaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 15:30:15 -0400
In-Reply-To: <1241635518.13702.37.camel@hazard2.francoudi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 May 2009 21:45:18 Vladimir Ivashchenko wrote:
> On Wed, 2009-05-06 at 05:36 +0200, Eric Dumazet wrote:
> > Ah, I forgot about one patch that could help your setup too (if using
> > more than one cpu on NIC irqs of course), queued for 2.6.31
>
> I have tried the patch. Didn't make a noticeable difference. Under 850
> mbps HTB+sfq load, 2.6.29.1, four NICs / two bond ifaces, IRQ balancing,
> the dual-core server has only 25% idle on each CPU.
>
> What's interesting, the same 850mbps load, identical machine, but with
> only two NICs and no bond, HTB+esfq, kernel 2.6.21.2 => 60% CPU idle.
> 2.5x overhead.

Probably oprofile can sched some light on this.
On my own experience IRQ balancing hurt performance a lot, because of cache 
misses.

