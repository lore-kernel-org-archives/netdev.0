From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.30 3/3] gianfar: Fix stashing support
Date: Wed, 04 Feb 2009 16:44:02 -0800 (PST)
Message-ID: <20090204.164402.259881113.davem@davemloft.net>
References: <1233710223-17808-3-git-send-email-afleming@freescale.com>
	<1233710223-17808-4-git-send-email-afleming@freescale.com>
	<1233710223-17808-5-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45320
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761478AbZBEAoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:44:06 -0500
In-Reply-To: <1233710223-17808-5-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue,  3 Feb 2009 19:17:03 -0600

> Stashing is only supported on the 85xx (e500-based) SoCs.  The 83xx and 86xx
> chips don't have a proper cache for this.  U-Boot has been updated to add
> stashing properties to the device tree nodes of gianfar devices on 85xx.  So
> now we modify Linux to keep stashing off unless those properties are there.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Also applied, thanks Andy.
