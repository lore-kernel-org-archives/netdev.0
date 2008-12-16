From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 07/14] gianfar: Enable padding and Optimize the
 frame prepended bytes handling
Date: Tue, 16 Dec 2008 15:31:22 -0800 (PST)
Message-ID: <20081216.153122.123560415.davem@davemloft.net>
References: <1229469667-25002-6-git-send-email-afleming@freescale.com>
	<1229469667-25002-7-git-send-email-afleming@freescale.com>
	<1229469667-25002-8-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org,
	Dai.Haruki@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52216
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754921AbYLPXbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:31:21 -0500
In-Reply-To: <1229469667-25002-8-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:21:00 -0600

> The eTSEC can prepend up to 32 bytes to a received frame, usually for the
> purpose of aligning the IP address to a word boundary, so this turns it on.
> 
> While we're in there, make the handling of the pre-frame bytes (padding and
> Frame Control Block) cleaner.
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
