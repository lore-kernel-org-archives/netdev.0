From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] tg3: MII => TP
Date: Sun, 21 Oct 2007 21:00:27 -0700 (PDT)
Message-ID: <20071021.210027.08881074.davem@davemloft.net>
References: <20071021.161442.22476508.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC002AABB03@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752437AbXJVEAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 00:00:14 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABB03@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 21 Oct 2007 20:49:25 -0700

> MII in this ethtool context means an MII connector on the card
> that can connect to an external transceiver, right?
> 
> Or does it mean internal MII interface to the PHY?

Good question.  Looking at drivers it's set randomly.

Probably you are right and it's supposed to mean you can specify
PORT_MII in ethtool_cmd->port to select the external MII connector.

Please resubmit this change after the PCI error recovery
issues are resolved.

Thanks.
