From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 2/2] gianfar: Fix potential soft reset race
Date: Wed, 04 Feb 2009 16:38:19 -0800 (PST)
Message-ID: <20090204.163819.147023307.davem@davemloft.net>
References: <1233710223-17808-1-git-send-email-afleming@freescale.com>
	<1233710223-17808-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761434AbZBEAiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:38:23 -0500
In-Reply-To: <1233710223-17808-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue,  3 Feb 2009 19:17:00 -0600

> SOFT_RESET must be asserted for at least 3 TX clocks in order for it to work
> properly.  The syncs in the gfar_write() commands have been hiding this, but
> we need to guarantee it.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Also applied.
