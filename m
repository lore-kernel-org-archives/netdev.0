From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 15:17:53 +0200
Message-ID: <469B7001.3090604@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50086 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756445AbXGPNTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:19:25 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
>>>>Today a new site joined our Linux IPSec VPN, now all the 
>>>
>>>other routers
>>>
>>>>(all 2.6.22) freeze hard reproducible.
> 
> 
> The problem is more general und ugly than I thought.
> 
> I took 2 arbitrary boxes, one behind an Ethernet (A, Kernel 2.6.21, MTU
> 1500), one behind ADSL (B, 2.4.x, 1492).
> Established a tunnel, copied a file from site A to B through the tunnel
> and router A died in the same moment.
> 
> Out of my feeling this worked fine some kernel releases earlier.
> 
> As written in this thread before, I see an external need-to-frag-ICMP,
> no tunnel need-to-frag will be thrown, box freezes.
> 
> You should be able to reproduce it with any network path with a smaller
> MTU?!?


I'm running IPsec in the same setup as you describe above without
problems. I'm probably not seeing ICMP frag requireds on the wire
though since I believe the entire path is >= 1492.

Could you try to find out whether those are responsible?
