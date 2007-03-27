From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LVS: Send ICMP unreachable responses to end-users when
 real-servers are removed
Date: Mon, 26 Mar 2007 18:04:08 -0700 (PDT)
Message-ID: <20070326.180408.18304339.davem@davemloft.net>
References: <20070211030441.GB3383@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkrzyszt@tis.icnet.pl, ja@ssi.bg,
	wensong@linux-vs.org, jmack@wm7d.net, ratz@drugphish.ch
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933887AbXC0BEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 21:04:10 -0400
In-Reply-To: <20070211030441.GB3383@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Horms <horms@verge.net.au>
Date: Sun, 11 Feb 2007 12:04:43 +0900

> Hi,
> 
> this is a small patch by  Janusz Krzysztofik to ip_route_output_slow()
> that allows VIP-less LVS linux director to generate packets originating
> >From VIP if sysctl_ip_nonlocal_bind is set.
> 
> In a nutshell, the intention is for an LVS linux director to be able
> to send ICMP unreachable responses to end-users when real-servers are
> removed.
> 
> http://archive.linuxvirtualserver.org/html/lvs-users/2007-01/msg00106.html
> 
> I'm not really sure about the correctness of this approach,
> so I am sending it here to netdev for review
> 
> Cc: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied to net-2.6.22, thanks Simon.
