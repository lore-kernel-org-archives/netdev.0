From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 03/14] gianfar: Convert gianfar to an
 of_platform_driver
Date: Tue, 16 Dec 2008 15:29:23 -0800 (PST)
Message-ID: <20081216.152923.04830200.davem@davemloft.net>
References: <1229469667-25002-2-git-send-email-afleming@freescale.com>
	<1229469667-25002-3-git-send-email-afleming@freescale.com>
	<1229469667-25002-4-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752799AbYLPX3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:29:21 -0500
In-Reply-To: <1229469667-25002-4-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:20:56 -0600

> Does the same for the accompanying MDIO driver, and then modifies the TBI
> configuration method.  The old way used fields in einfo, which no longer
> exists.  The new way is to create an MDIO device-tree node for each instance
> of gianfar, and create a tbi-handle property to associate ethernet controllers
> with the TBI PHYs they are connected to.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
