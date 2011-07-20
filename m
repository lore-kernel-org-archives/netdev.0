From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: sch_generic warn_on (timed out)
Date: Wed, 20 Jul 2011 23:53:54 +0200
Message-ID: <20110720215354.GA10382@electric-eye.fr.zoreil.com>
References: <20110711204834.GA4950@redhat.com> <20110711.141701.1453197953333902027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54315 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908Ab1GTWJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 18:09:09 -0400
Content-Disposition: inline
In-Reply-To: <20110711.141701.1453197953333902027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> > duping all others against. It seems to be showing up on a variety of different
> > hardware (r8169, atl1c, ipheth, e1000e, 8139too). Do all these drivers need
> > fixing ? or is it just 'crap hardware' ?

The r8169 driver has seen driver bugs, poorly supported hardware,
"interesting" hardware, evolving hardware, false alarm reports, crappy
maintainership and almost anything one can think of (as long as you do
not think about public datasheets or errata).

[...]
> I would track this on a per-device basis if I were you, instead of
> combining them all into one super-bug.

+1 +1 +1

One could almost split the r8169 problems further by XID, then eventually
by platform. 

-- 
Ueimor
