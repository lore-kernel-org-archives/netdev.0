From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: RxConfig hack for the 8168evl.
Date: Fri, 22 Jun 2012 21:49:02 -0700 (PDT)
Message-ID: <20120622.214902.877817727539946317.davem@davemloft.net>
References: <20120620220918.GA2785@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org, thomas.pi@arcor.de
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337Ab2FWEtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 00:49:03 -0400
In-Reply-To: <20120620220918.GA2785@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 21 Jun 2012 00:09:18 +0200

> The 8168evl (RTL_GIGA_MAC_VER_34) based Gigabyte GA-990FXA motherboards
> are very prone to NETDEV watchdog problems without this change. See
> https://bugzilla.kernel.org/show_bug.cgi?id=42899 for instance.
> 
> I don't know why it *works*. It's depressingly effective though.
> 
> For the record:
> - the problem may go along IOMMU (AMD-Vi) errors but it really looks
>   like a red herring.
> - the patch sets the RX_MULTI_EN bit. If the 8168c doc is any guide,
>   the chipset now fetches several Rx descriptors at a time.
> - long ago the driver ignored the RX_MULTI_EN bit.
>   e542a2269f232d61270ceddd42b73a4348dee2bb changed the RxConfig
>   settings. Whatever the problem it's now labeled a regression.
> - Realtek's own driver can identify two different 8168evl devices
>   (CFG_METHOD_16 and CFG_METHOD_17) where the r8169 driver only
>   sees one. It sucks.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks Francois.
