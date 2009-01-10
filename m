From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Use device_set_wakeup_enable
Date: Fri, 09 Jan 2009 23:09:07 -0800 (PST)
Message-ID: <20090109.230907.106580567.davem@davemloft.net>
References: <20090109135317.GC6473@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, gwilford@gmail.com,
	degnbol@danbbs.dk
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753440AbZAJHJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:09:06 -0500
In-Reply-To: <20090109135317.GC6473@bayes.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Date: Fri, 9 Jan 2009 14:53:17 +0100

> Since dev->power.should_wakeup bit is used by the PCI core to
> decide whether the device should wake up the system from sleep
> states, set this bit by calling device_set_wakeup_enable().
> 
> This restores proper WOL for the 3c59x driver.
> 
> Reported-and-tested-by: Graeme Wilford <gwilford@gmail.com>
> Reported-by: Gunnar Degnbol <degnbol@danbbs.dk>
> Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

Applied.
