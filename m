From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Mon, 14 May 2007 03:35:04 -0700 (PDT)
Message-ID: <20070514.033504.48528120.davem@davemloft.net>
References: <200704271705.l3RH5Brw026873@hera.kernel.org>
	<4648382E.8030009@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, netdev@vger.kernel.org, jkrzyszt@tis.icnet.pl
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38206
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754907AbXENKe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 06:34:59 -0400
In-Reply-To: <4648382E.8030009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 14 May 2007 12:21:34 +0200

> This allows any user to send spoofed packets when ip_nonlocal_bind
> is set, which is a quite big change in behaviour of this option.
> The TPROXY patches include a similar change, but use a flag in
> struct flowi that requires CAP_NET_ADMIN to be set, which seems like
> a better idea. Alternatively you could just use input routing for
> non-local source addresses like ip_route_me_harder does.

Good point.

> BTW, there doesn't even seem to be a spot where IPVS calls
> ip_route_output with the source address set. What exactly is this
> needed for?

I suppose he has a patch to make use of it, but was waiting
for this route.c change to go in first.
