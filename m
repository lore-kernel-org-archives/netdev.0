From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: adding new device to bridge should enable if up
Date: Wed, 07 Mar 2007 16:12:03 -0800 (PST)
Message-ID: <20070307.161203.26532896.davem@davemloft.net>
References: <20070307160355.0e27f425@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992796AbXCHAME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 19:12:04 -0500
In-Reply-To: <20070307160355.0e27f425@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 7 Mar 2007 16:03:55 -0800

> One change introduced by the workqueue removal patch is that adding an
> interface that is up to a bridge which is also up does not ever call
> br_stp_enable_port(), leaving the port in DISABLED state until we do
> ifconfig down and up or link events occur.
> 
> The following patch to the br_add_if function fixes it.
> This is a regression introduced in 2.6.21.
> 
> Submitted-by: Aji_Srinivas@emc.com
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, but:

> +	if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
> +	    (br->dev->flags & IFF_UP)) 

I had to fix up the trailing whitespace on that second line.

Please use "git apply --check --whitespace=error-all"
or similar to validate the patches you send me.

Thanks.
