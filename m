From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: convert mc_lock to spinlock
Date: Wed, 17 Feb 2010 18:49:00 -0800 (PST)
Message-ID: <20100217.184900.89075929.davem@davemloft.net>
References: <20100217182859.3a4f30de@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757225Ab0BRCso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 21:48:44 -0500
In-Reply-To: <20100217182859.3a4f30de@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Feb 2010 18:28:59 -0800

> Only used for writing, so convert to spinlock
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

That's an overwhelmingly clear cut case for me.

Applied, thanks Stephen.
