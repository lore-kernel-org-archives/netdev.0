From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Wed, 30 Apr 2008 14:58:20 -0700 (PDT)
Message-ID: <20080430.145820.50450486.davem@davemloft.net>
References: <20080430214845.GC14219@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kmansley@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753156AbYD3V6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:58:21 -0400
In-Reply-To: <20080430214845.GC14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Apr 2008 22:48:46 +0100

> Large Receive Offload (LRO) destroys packet headers that should be
> preserved when forwarding.  Currently it also triggers a BUG() or WARN()
> in skb_gso_segment().  We should disable it wherever forwarding is
> enabled, and discard LRO skbs with a warning if it is turned back on.

Thanks for reposting your work, I'll take a closer look at these
two patches later today.
