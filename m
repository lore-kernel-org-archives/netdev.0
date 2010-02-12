From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] be2net: fix to limit max vlans supported in
 certain skews
Date: Fri, 12 Feb 2010 12:29:38 -0800 (PST)
Message-ID: <20100212.122938.33887795.davem@davemloft.net>
References: <20100209113447.GA10511@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757641Ab0BLU3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:29:23 -0500
In-Reply-To: <20100209113447.GA10511@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Tue, 9 Feb 2010 17:04:57 +0530

> In certain skews the ASIC can support only 16 vlans per interface.
> Once the limit is crossed, the ASIC is programmed in vlan promiscuous mode.
> Switch off the vlan promiscuous mode once the number of vlans
> falls back to the max vlans supported.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied to net-next-2.6
