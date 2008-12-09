From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net (tg3): Fix failure to enable WoL by default when
 possible (rev. 2)
Date: Tue, 09 Dec 2008 00:20:07 -0800 (PST)
Message-ID: <20081209.002007.203471603.davem@davemloft.net>
References: <200812081250.59095.rjw@sisk.pl>
	<200812081252.55715.rjw@sisk.pl>
	<20081208190403.GA27341@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mchan@broadcom.com, netdev@vger.kernel.org,
	jeff@garzik.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45491
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752142AbYLIIUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 03:20:07 -0500
In-Reply-To: <20081208190403.GA27341@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 8 Dec 2008 11:04:03 -0800

> This has mostly been fixed up already in Dave Miller's tree.  In that
> tree, the WOL capability advertisements happens at the end of the
> tg3_get_eeprom_hw_cfg() function.
> 
> Your patch did uncover a bug though.  The removal of device_may_wakeup()
> in the first hunk of your patch still needs to be done.

Ok, can someone post a patch that takes care of that against
net-next-2.6?

Thanks in advance!
