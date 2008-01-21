From: David Miller <davem@davemloft.net>
Subject: Re: [MACVLAN]: Fix thinko in macvlan_transfer_operstate()
Date: Mon, 21 Jan 2008 00:47:25 -0800 (PST)
Message-ID: <20080121.004725.240179452.davem@davemloft.net>
References: <47935EEC.6010402@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57985
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758071AbYAUIrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 03:47:19 -0500
In-Reply-To: <47935EEC.6010402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 20 Jan 2008 15:47:08 +0100

> [MACVLAN]: Fix thinko in macvlan_transfer_operstate()
> 
> When the lower device's carrier is off, the macvlan devices's
> carrier state should be checked to decide whether it needs to
> be turned off. Currently the lower device's state is checked
> a second time.
> 
> This still works, but unnecessarily tries to turn off the
> carrier when its already off.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.25, thanks.
