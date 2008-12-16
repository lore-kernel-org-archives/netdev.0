From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Remove unnecessary "reset" fixups in
 genphy_setup_forced
Date: Tue, 16 Dec 2008 15:39:59 -0800 (PST)
Message-ID: <20081216.153959.53163736.davem@davemloft.net>
References: <1229469389-24926-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45734
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751010AbYLPXj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:39:58 -0500
In-Reply-To: <1229469389-24926-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:16:29 -0600

> genphy_setup_forced hasn't actually reset the PHY for a long time,
> but a comment to that effect remained in the code, so code continued
> to act as if it *had* reset the PHY, and called the necessary fixup
> functions to respond to a PHY reset.  With no reset, those functions
> are no longer needed, so we remove them.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
