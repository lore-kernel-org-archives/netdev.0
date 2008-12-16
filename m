From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 10/14] gianfar: Make all BD status writes 32-bit
Date: Tue, 16 Dec 2008 15:35:17 -0800 (PST)
Message-ID: <20081216.153517.195238948.davem@davemloft.net>
References: <1229469667-25002-9-git-send-email-afleming@freescale.com>
	<1229469667-25002-10-git-send-email-afleming@freescale.com>
	<1229469667-25002-11-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org,
	Dai.Haruki@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40677
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753521AbYLPXfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:35:16 -0500
In-Reply-To: <1229469667-25002-11-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:21:03 -0600

> Whenever we want to update the status field in a BD, we usually want to
> update the length field, too.  By combining them into one 32-bit field, we
> reduce the number of stores to memory shared with the controller, and we
> eliminate the need for order-enforcement, as the length and "READY" bit are
> now updated atomically at the same time.
> 
> Signed-off-by: Dai Haruki <Dai.Haruki@freescale.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.

But this seems to point out that all of this descriptor
code needs to be endianness annotated and use endianness
types like __be32
