From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] be2net: fix spurious interrupt handling in
 intx mode
Date: Fri, 03 Jul 2009 20:14:04 -0700 (PDT)
Message-ID: <20090703.201404.125512996.davem@davemloft.net>
References: <20090701110607.GA23588@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34701
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752983AbZGDDN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 23:13:58 -0400
In-Reply-To: <20090701110607.GA23588@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 1 Jul 2009 16:36:07 +0530

>  Occasionally we may see an interrupt without an event in the eq.
>  In intx, we currently see the event queue and return IRQ_NONE causing
>  a the irq to be disabled ("no one cared".) Instead, read the CEV_ISR
>  reg to check the existence of the interrupt.
> 
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
