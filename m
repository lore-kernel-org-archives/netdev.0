From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PHYLIB mdio fixes #2
Date: Thu, 25 Dec 2008 16:50:50 -0800 (PST)
Message-ID: <20081225.165050.227230570.davem@davemloft.net>
References: <m3r644aqnv.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752140AbYLZAus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:50:48 -0500
In-Reply-To: <m3r644aqnv.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Fri, 19 Dec 2008 20:52:36 +0100

> The PHYLIB mdio code has more problems in error paths:
> - mdiobus_release can be called before bus->state is set to
>   MDIOBUS_REGISTERED
> - mdiobus_scan allocates resources which need to be freed
> - the comment is wrong, the resistors used are actually pull-ups.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

Applied, thank you.
