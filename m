From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Unhardcode port numbers
Date: Mon, 26 Oct 2015 18:24:48 -0700 (PDT)
Message-ID: <20151026.182448.1456043076320452877.davem@davemloft.net>
References: <1445627468-16084-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, linux@roeck-us.net
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbbJ0BIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 21:08:09 -0400
In-Reply-To: <1445627468-16084-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 23 Oct 2015 12:11:08 -0700

> While the current driver mostly supports BCM7445 which has a hardcoded
> location for its MoCA port on port 7 and port 0 for its internal PHY,
> this is not necessarily true for all other chips out there such as
> BCM3390 for instance.
> 
> Walk the list of ports from Device Tree, get their port number ("reg"
> property), and then parse the "phy-mode" property and initialize two
> internal variables: moca_port and a bitmask of internal PHYs. Since we
> use interrupts for the MoCA port, we introduce two helper functions to
> enable/disable interrupts and do this at the appropriate bank (INTRL2_0
> or INTRL2_1).
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
