From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 15:09:03 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Beschorner Daniel" <Daniel.Beschorner@facton.com>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:53781 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758079AbXGPNJK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:09:10 -0400
Content-class: urn:content-classes:message
In-reply-to: <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > Today a new site joined our Linux IPSec VPN, now all the 
> > other routers
> > > (all 2.6.22) freeze hard reproducible.

The problem is more general und ugly than I thought.

I took 2 arbitrary boxes, one behind an Ethernet (A, Kernel 2.6.21, MTU
1500), one behind ADSL (B, 2.4.x, 1492).
Established a tunnel, copied a file from site A to B through the tunnel
and router A died in the same moment.

Out of my feeling this worked fine some kernel releases earlier.

As written in this thread before, I see an external need-to-frag-ICMP,
no tunnel need-to-frag will be thrown, box freezes.

You should be able to reproduce it with any network path with a smaller
MTU?!?

Daniel
