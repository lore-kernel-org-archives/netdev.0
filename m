From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: check min TTL on received ICMP packets
Date: Fri, 19 Mar 2010 21:08:01 -0700 (PDT)
Message-ID: <20100319.210801.39166378.davem@davemloft.net>
References: <20100318142732.4de0f8d7@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056Ab0CTEHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 00:07:38 -0400
In-Reply-To: <20100318142732.4de0f8d7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 18 Mar 2010 14:27:32 -0700

> This adds RFC5082 checks for TTL on received ICMP packets.
> It adds some security against spoofed ICMP packets
> disrupting GTSM protected sessions.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
  
Applied.

> Please apply to 2.6.33 since it basically a "follow correct RFC"
> fix to original GTSM patch.

Queued up for -stable, thanks!
