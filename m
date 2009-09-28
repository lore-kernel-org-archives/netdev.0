From: David Miller <davem@davemloft.net>
Subject: Re: tg3 and Broadcom PHY driver
Date: Mon, 28 Sep 2009 14:55:22 -0700 (PDT)
Message-ID: <20090928.145522.151077608.davem@davemloft.net>
References: <4AC1223B.8070903@embedded-sol.com>
	<20090928.141527.193009676.davem@davemloft.net>
	<4AC13036.8030506@embedded-sol.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: felix@embedded-sol.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753380AbZI1VzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 17:55:03 -0400
In-Reply-To: <4AC13036.8030506@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Radensky <felix@embedded-sol.com>
Date: Mon, 28 Sep 2009 23:52:54 +0200

> Yes, moving CONFIG_TIGON3 right after CONFIG_PHYLIB in
> drivers/net/Makefile fixes the problem for me.

Thanks for testing.

We really need to fix this generically.

Does anyone think that moving the MDIO/MII/PHY layer objects
to the top of drivers/net/Makefile will break anything?

If not, that's what we should do I think.
