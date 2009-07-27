From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: irda: init spinlock after memcpy
Date: Mon, 27 Jul 2009 10:49:56 -0700 (PDT)
Message-ID: <20090727.104956.154293001.davem@davemloft.net>
References: <alpine.LFD.2.00.0907271407590.2936@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752735AbZG0Rtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:49:49 -0400
In-Reply-To: <alpine.LFD.2.00.0907271407590.2936@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 27 Jul 2009 14:12:24 +0200 (CEST)

> From: Deepak Saxena <dsaxena@mvista.com>
> 
> irttp_dup() copies a tsap_cb struct, but does not initialize the
> spinlock in the new structure, which confuses lockdep.
> 
> Signed-off-by: Deepak Saxena <dsaxena@mvista.com>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Applied.
