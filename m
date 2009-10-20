From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] can: provide library functions for skb allocation
Date: Mon, 19 Oct 2009 23:05:49 -0700 (PDT)
Message-ID: <20091019.230549.29520350.davem@davemloft.net>
References: <4ADB6243.2040109@grandegger.com>
	<20091019.215440.256002623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	haas@ems-wuensche.com, anantgole@ti.com, mkl@pengutronix.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40547
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753544AbZJTGF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 02:05:27 -0400
In-Reply-To: <20091019.215440.256002623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 19 Oct 2009 21:54:40 -0700 (PDT)

> Applied, thanks.

Actually I have to back this out, you have to add an extern
declaration for these public functions to a header the CAN
drivers will see, or else there'll be build warnings and
errors.

I wonder if you actually did this, but forgot that part of
the change or lost it somehow while respinning this.

Please fix this up and resubmit, thanks.
