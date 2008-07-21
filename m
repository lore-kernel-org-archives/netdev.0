From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 16:15:25 +0200
Message-ID: <488499FD.5090300@s5r6.in-berlin.de>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721135024.GA18320@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:42643 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbYGUOQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 10:16:04 -0400
In-Reply-To: <20080721135024.GA18320@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> I'm wondering, couldnt we warn about the removed pci express support via 
> the kernel log? Some simple printk. (Perhaps also with a default-off 
> .config option that shuts up this warning for users who intentionally 
> boot E1000=y without e1000e support.)

e1000_init_module() already has two printk()s.  A third unconditional
one won't hurt a lot.  The first two could also be joined.
-- 
Stefan Richter
-=====-==--- -=== =-=-=
http://arcgraph.de/sr/
