From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 delay / segfault
Date: Sun, 14 Oct 2012 23:32:24 +0200
Message-ID: <20121014213224.GA23396@electric-eye.fr.zoreil.com>
References: <50787109.7080605@antcom.de> <20121012210503.GA2054@electric-eye.fr.zoreil.com> <50789649.3080202@antcom.de> <50793B6F.50507@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: Roland Stigge <stigge@antcom.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56606 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603Ab2JNVwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 17:52:54 -0400
Content-Disposition: inline
In-Reply-To: <50793B6F.50507@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Stigge <stigge@antcom.de> :
[...]
> What does the different device ID, XID and IRQ number mean ?

XID identifies the chipset. If the chipset stops responding - all 1 bits -
the device can not be identified.

> How can we force the device out of D3 power state?
> 
> I also compared with kernel 3.5, and it seems like a regression to me,
> With 3.5, it works and tells on resume:

Can you try both a 3.5 kernel with the 3.6 r8169 driver and a 3.6 kernel
with the 3.5 r8169 driver ?

-- 
Ueimor
