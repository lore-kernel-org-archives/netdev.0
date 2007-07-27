From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH] forcedeth: mac address correct
Date: Sat, 28 Jul 2007 00:50:10 +0100
Message-ID: <46AA84B2.4030305@simon.arlott.org.uk>
References: <46A96798.5000106@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:45662 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938206AbXG0XuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 19:50:21 -0400
In-Reply-To: <46A96798.5000106@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/07/07 04:33, Ayaz Abdulla wrote:
> In older chipsets, the mac address was stored in reversed order.
> However, in newer chipsets, the mac address is in correct order. This
> patch takes those newer chipsets into account and does not rely on a
> special bit setup by BIOS'.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 

-	if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
+	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
+	    (id->driver_data & DEV_HAS_CORRECT_MACADDR) {

This will not compile.

-- 
Simon Arlott
