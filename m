From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Wed, 30 Apr 2008 22:48:46 +0100
Message-ID: <20080430214845.GC14219@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:36643 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760270AbYD3Vs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:48:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Large Receive Offload (LRO) destroys packet headers that should be
preserved when forwarding.  Currently it also triggers a BUG() or WARN()
in skb_gso_segment().  We should disable it wherever forwarding is
enabled, and discard LRO skbs with a warning if it is turned back on.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
