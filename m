From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix checks on unsigned in w90p910_ether_probe()
Date: Thu, 29 Oct 2009 23:06:24 -0700 (PDT)
Message-ID: <20091029.230624.125832796.davem@davemloft.net>
References: <4ADDFE0C.3020400@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	mcuos.com@gmail.com
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50191
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbZJ3GGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 02:06:00 -0400
In-Reply-To: <4ADDFE0C.3020400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 20 Oct 2009 20:14:36 +0200

> ether->txirq and ->rxirq are unsigned
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

platform_get_irq() returns a signed int so the intention
is more likely that catching negative value returns
was intended.

Probably the correct fix is to mark txirq and rxirq as
plain 'int'.
