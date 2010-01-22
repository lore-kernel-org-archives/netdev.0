From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 V2] net: Add Aeroflex Gaisler 10/100/1G Ethernet
 MAC driver
Date: Thu, 21 Jan 2010 22:47:48 -0800 (PST)
Message-ID: <20100121.224748.251929245.davem@davemloft.net>
References: <1263827277-7165-1-git-send-email-kristoffer@gaisler.com>
	<1263827277-7165-2-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: kristoffer@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46846
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750729Ab0AVGrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 01:47:36 -0500
In-Reply-To: <1263827277-7165-2-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristoffer Glembo <kristoffer@gaisler.com>
Date: Mon, 18 Jan 2010 16:07:57 +0100

> +#undef DEBUG_TX_PACKETS
> +#undef DEBUG_RX_PACKETS

There is an existing facility for doing run-time debug
enabling for things like this.

So instead of this ifdef mess, make use of netdev->msg_enable
to control various types of debugging messages.

Thanks.
