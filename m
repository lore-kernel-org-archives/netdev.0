From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev: add support for Receive Side Scaling hash
 control
Date: Tue, 30 Mar 2010 23:52:03 -0700 (PDT)
Message-ID: <20100330.235203.258276029.davem@davemloft.net>
References: <20100328154448.701c89ee@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45820
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756151Ab0CaGwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:52:02 -0400
In-Reply-To: <20100328154448.701c89ee@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 28 Mar 2010 15:44:48 -0700

> This adds ethtool and device feature flag to allow control
> of Receive Side Scaling hashing supported by many modern
> controllers.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> I am working on RSS for sky2 device, but the hardware isn't fully cooperating
> but thought others might want to use same API.

I assume you didn't intend this to be applied because it uses
the same value as you choose for RXHASH.

If you want this applied, resubmit against your RXHASH changes.

Thanks!
