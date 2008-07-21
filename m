From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 13:28:49 +0200
Message-ID: <488472F1.4020609@s5r6.in-berlin.de>
References: <20080720.104411.81744468.davem@davemloft.net>	<alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org> <20080720.180304.51601407.davem@davemloft.net> <4883E465.4050405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmorris@namei.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:42271 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbYGUL32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 07:29:28 -0400
In-Reply-To: <4883E465.4050405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
>>> 	  Security table (IP_NF_SECURITY) [Y/n/?] (NEW) ?
...
> This is only the NETFILTER_ADVANCED=n default (for SECURITY=y).
> The netfilter defaults for NETFILTER_ADVANCED=n should be m/y for
> things that are needed by mainstream distributions for normal
> usage.

Don't ask what mainstream distributors would choose, ask how "make
oldconfig" or "make silentoldconfig" should behave.  They should not add
features that weren't there before and are not necessary to continue
using all features of the old configuration.
-- 
Stefan Richter
-=====-==--- -=== =-=-=
http://arcgraph.de/sr/
