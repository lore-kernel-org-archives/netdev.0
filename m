From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Tue, 21 Apr 2009 01:54:14 -0700 (PDT)
Message-ID: <20090421.015414.259541482.davem@davemloft.net>
References: <20090417.043945.67766586.davem@davemloft.net>
	<1240225027-14721-1-git-send-email-haavard.skinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, michael@free-electrons.com,
	netdev@vger.kernel.org
To: haavard.skinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751425AbZDUIyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:54:21 -0400
In-Reply-To: <1240225027-14721-1-git-send-email-haavard.skinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Mon, 20 Apr 2009 12:57:07 +0200

> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> 
> With this patch in place, I'm successfully able to use the netconsole
> mechanism with the Calao USB-A9263 board, which uses the AT91SAM9263
> CPU, which in terms of Ethernet controller is supported by the macb
> driver.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> [haavard.skinnemoen@atmel.com: disable_irq() -> local_irq_save()]
> Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>

This patch does not apply to the current tree.

The macb driver has been converted over to netdev_ops, and therefore
these accesses to ->poll_controller are not correct.
