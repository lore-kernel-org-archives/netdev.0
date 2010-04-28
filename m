From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/17] sfc: Extend the legacy interrupt workarounds
Date: Wed, 28 Apr 2010 12:45:47 -0700 (PDT)
Message-ID: <20100428.124547.48527963.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272482907.2549.22.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49113
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756880Ab0D1Tpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:45:41 -0400
In-Reply-To: <1272482907.2549.22.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:28:27 +0100

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Siena has two problems with legacy interrupts:
>   1. There is no synchronisation between the ISR read completion,
>      and the interrupt deassert message.
>   2. A downstream read at the "wrong" moment can return 0, and
>      suppress generating the next interrupt.
> 
> Falcon should suffer from both of these, and it appears it does.
> Enable EFX_WORKAROUND_15783 on Falcon as well.
> 
> Also, when we see queues == 0, ensure we always schedule or rearm
> every event queue.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
