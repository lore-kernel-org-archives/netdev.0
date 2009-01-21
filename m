From: David Miller <davem@davemloft.net>
Subject: Re: [Resubmit] [PATCH] usb/mcs7830: Don't use buffers from stack
 for USB transfers
Date: Wed, 21 Jan 2009 12:56:38 -0800 (PST)
Message-ID: <20090121.125638.152447234.davem@davemloft.net>
References: <200901211248.30794.ceggers@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
To: ceggers@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35063
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752001AbZAUU4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 15:56:36 -0500
In-Reply-To: <200901211248.30794.ceggers@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Eggers <ceggers@gmx.de>
Date: Wed, 21 Jan 2009 12:48:30 +0100

> mcs7830_set_reg() and mcs7830_get_reg() are called with buffers
> from stack which must not be used directly for USB transfers.
> This causes corruption of the stack particulary on non x86
> architectures because DMA may be used for these transfers.
> 
> Signed-off-by: Christian Eggers <christian.eggers@kathrein.de>

Applied, thanks everyone.
