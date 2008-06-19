From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Disable LRO on devices that are forwarding
Date: Thu, 19 Jun 2008 16:21:45 -0700 (PDT)
Message-ID: <20080619.162145.212568056.davem@davemloft.net>
References: <cover.1213898165.git.bhutchings@solarflare.com>
	<20080619180735.GT5350@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	kmansley@solarflare.com, herbert@gondor.apana.org.au,
	shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752017AbYFSXVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:21:46 -0400
In-Reply-To: <20080619180735.GT5350@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 19 Jun 2008 19:07:36 +0100

> Large Receive Offload (LRO) is only appropriate for packets that are
> destined for the host, and should be disabled if received packets may be
> forwarded.  It can also confuse the GSO on output.
> 
> Add dev_disable_lro() function which uses the appropriate ethtool ops to
> disable LRO if enabled.
> 
> Add calls to dev_disable_lro() in br_add_if() and functions that enable
> IPv4 and IPv6 forwarding.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Looks good, applied to net-next-2.6
