From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] net: Improve cache line coherency of
 ingress qdisc
Date: Tue, 12 Feb 2008 23:14:03 -0800 (PST)
Message-ID: <20080212.231403.224385102.davem@davemloft.net>
References: <478F364C.1000301@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: nturton@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49091
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755052AbYBMHNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 02:13:31 -0500
In-Reply-To: <478F364C.1000301@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Turton <nturton@solarflare.com>
Date: Thu, 17 Jan 2008 11:04:44 +0000

> Move the ingress qdisc members of struct net_device from the transmit
> cache line to the receive cache line to avoid cache line ping-pong.
> These members are only used on the receive path.
> 
> Signed-off-by: Neil Turton <nturton@solarflare.com>

Looks reasonable, applied, thanks!
