From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec freeze
Date: Sun, 15 Jul 2007 17:00:40 +0200
Message-ID: <469A3698.5020105@trash.net>
References: <3C59DB883F7B0B4D8096010D45ACCD13230225@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59464 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758116AbXGOPBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 11:01:50 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13230225@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
> Today a new site joined our Linux IPSec VPN, now all the other routers
> (all 2.6.22) freeze hard reproducible.


Do the other routers all do IPsec or just one of them?

> No oops, no sysreq, only hard reset rewakes them.

> 
> The only difference of the new site compared to the others: ADSL, thus a
> MTU of 1492, the others have 1500.
> Disabling IPSec und doing normal operations between the routers is fine,
> PMTU is honored correctly.
> If I set the MTU of the other routers to 1492 I can avoid the IPSec
> crash.
> 
> Some kind of strange need-to-frag-ICMP that causes such things?
> Any ideas how to debug this?


If you can't get any information from your boxes, a testcase that can
be used to reproduce this would help.

> Here a log of another death from inside the tunnel (last packet is again
> the time of crash):
> The Tunnel MTU of 1430 is correct for an outer MTU of 1500, but the
> additional -8 doesn't take place?!?
> 
> 05:17:18.563448 IP 192.168.200.1.80 > 192.168.203.1.3084: tcp 1460
> 05:17:18.563468 IP 192.168.200.254 > 192.168.200.1: ICMP 192.168.203.1
> unreachable - need to frag (mtu 1430), length 556


Does the router use a MTU of 1492 itself or is there another DSL
router or something like that connected by ethernet?

