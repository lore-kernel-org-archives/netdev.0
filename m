From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Fri, 18 May 2007 02:05:25 -0700 (PDT)
Message-ID: <20070518.020525.28394540.davem@davemloft.net>
References: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
	<464C857C.9070406@trash.net>
	<Pine.LNX.4.58.0705181043390.2665@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, horms@verge.net.au, jkrzyszt@tis.icnet.pl,
	netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34542
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754548AbXERJFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 05:05:23 -0400
In-Reply-To: <Pine.LNX.4.58.0705181043390.2665@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Fri, 18 May 2007 11:40:54 +0300 (EEST)

> On Thu, 17 May 2007, Patrick McHardy wrote:
> 
> > In any case some better solution than the current one needs to be
> > found, allowing users to send spoofed packets is far worse than
> > using a non-desired source address for ICMP packets.
> 
> 	yes, I would prefer the sysctl_ip_nonlocal_bind change to be
> removed until such solution is found.

Ok, I'll revert it.
