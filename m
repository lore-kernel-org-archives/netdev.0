From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] bluetooth: hci_bcsp.c small cleanups/api users
Date: Tue, 10 Jun 2008 12:49:00 -0700 (PDT)
Message-ID: <20080610.124900.216156348.davem@davemloft.net>
References: <200806092332.m59NW09M014556@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harvey.harrison@gmail.com,
	akinobu.mita@gmail.com, hidave.darkstar@gmail.com,
	marcel@holtmann.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752143AbYFJTtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:49:00 -0400
In-Reply-To: <200806092332.m59NW09M014556@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 09 Jun 2008 16:31:59 -0700

> Use bitrev16 from lib/bitrev.c.
> 
> Use the get_unaligned_be16 to get the crc from the packet, create a
> small helper function for this.
> 
> Fix a shadowed variable sparse warning:
> drivers/bluetooth/hci_bcsp.c:218:26: warning: symbol 'hdr' shadows an earlier one
> drivers/bluetooth/hci_bcsp.c:187:5: originally declared here
> 
> [akpm@linux-foundation.org: select CONFIG_BITREVERSE, noted by akinobu.mita@gmail.com]
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Cc: Akinobu Mita <akinobu.mita@gmail.com>
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dave Young <hidave.darkstar@gmail.com>
> Cc: Akinobu Mita <akinobu.mita@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6, thanks!
