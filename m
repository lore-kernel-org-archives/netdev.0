From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 15:26:48 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:55669 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759479AbXGPN0y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:26:54 -0400
Content-class: urn:content-classes:message
In-reply-to: <469B7001.3090604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>>>Today a new site joined our Linux IPSec VPN, now all the 
> >>>
> >>>other routers
> >>>
> >>>>(all 2.6.22) freeze hard reproducible.
> > 
> > 
> > The problem is more general und ugly than I thought.
> > 
> > I took 2 arbitrary boxes, one behind an Ethernet (A, Kernel 
> 2.6.21, MTU
> > 1500), one behind ADSL (B, 2.4.x, 1492).
> > Established a tunnel, copied a file from site A to B 
> through the tunnel
> > and router A died in the same moment.
> > 
> > Out of my feeling this worked fine some kernel releases earlier.
> > 
> > As written in this thread before, I see an external 
> need-to-frag-ICMP,
> > no tunnel need-to-frag will be thrown, box freezes.
> > 
> > You should be able to reproduce it with any network path 
> with a smaller
> > MTU?!?
> 
> 
> I'm running IPsec in the same setup as you describe above without
> problems. I'm probably not seeing ICMP frag requireds on the wire
> though since I believe the entire path is >= 1492.
> 
> Could you try to find out whether those are responsible?
> 

It's definitely the first large packet or corresponding ICMP that
triggers the crash, slow packets don't harm.
IPSec on pathes with a PMTU of 1500 works fine.
