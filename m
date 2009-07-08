From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r6040: restore MIER register correctly when IRQ
 line is shared
Date: Wed, 08 Jul 2009 10:50:48 -0700 (PDT)
Message-ID: <20090708.105048.17194821.davem@davemloft.net>
References: <200907081505.14846.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sdh4@iastate.edu, joe.chou@rdc.com.tw
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50701
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757169AbZGHRuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 13:50:46 -0400
In-Reply-To: <200907081505.14846.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 8 Jul 2009 15:05:14 +0200

> When the r6040 device IRQ line is shared we will enter the driver
> interrupt service routine, mask off the device interrupt enable
> register (MIER) and return with IRQ_NONE, we would then leave the
> device with interrupts disabled, this patch fixes that issue.
> 
> Reported-by: Steve Holland <sdh4@iastate.edu>
> Signed-off-by: Joe Chou <joe.chou@rdc.com.tw>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
