From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/8] use mutex instead of semaphore in VLSI 82C147 IrDA
 controller driver
Date: Mon, 09 Jul 2007 13:18:20 -0700 (PDT)
Message-ID: <20070709.131820.00929204.davem@davemloft.net>
References: <200707091851.l69IpBgq001734@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthias.kaehlcke@gmail.com,
	samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46051
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753028AbXGIUR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:17:58 -0400
In-Reply-To: <200707091851.l69IpBgq001734@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 09 Jul 2007 11:51:11 -0700

> From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> 
> The VLSI 82C147 IrDA controller driver uses a semaphore as mutex.  Use the
> mutex API instead of the (binary) semaphore.
> 
> Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
