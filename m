From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB
 transfers
Date: Tue, 20 Jan 2009 15:39:14 -0800 (PST)
Message-ID: <20090120.153914.208764614.davem@davemloft.net>
References: <200901210017.19038.arnd@arndb.de>
	<20090120.152345.78877396.davem@davemloft.net>
	<200901210037.51622.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ceggers@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753547AbZATXjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 18:39:13 -0500
In-Reply-To: <200901210037.51622.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 21 Jan 2009 00:37:51 +0100

> On a related topic, can we put something in place that can check for
> this error at run-time, like a WARN_ON(is_kernel_stack(addr)) in
> dma_map_single?

That would be something for the DMA API debugging patches that
have been floating around lately.
