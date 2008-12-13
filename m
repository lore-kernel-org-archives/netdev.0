From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/33] sfc: Add option to use a separate channel for TX
 completions
Date: Fri, 12 Dec 2008 21:36:36 -0800 (PST)
Message-ID: <20081212.213636.82919395.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212125216.GJ10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754521AbYLMFgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:36:35 -0500
In-Reply-To: <20081212125216.GJ10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:52:16 +0000

> From: Neil Turton <nturton@solarflare.com>
> 
> In a bidirectional forwarding test, we find that the best performance
> is achieved by sending the TX completion interrupts from one NIC to a
> CPU which shares an L2 cache with RX completion interrupts from the
> other NIC.  To facilitate this, add an option (through a module
> parameter) to create separate channels for RX and TX completion with
> separate IRQs when MSI-X is available.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
