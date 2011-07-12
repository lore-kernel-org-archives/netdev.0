From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 3/7] r8169: adjust the settings about RxConfig
Date: Tue, 12 Jul 2011 18:12:58 +0200
Message-ID: <20110712161258.GA6157@electric-eye.fr.zoreil.com>
References: <1309939088-31994-1-git-send-email-hayeswang@realtek.com> <1309939088-31994-3-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48818 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab1GLQ1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 12:27:36 -0400
Content-Disposition: inline
In-Reply-To: <1309939088-31994-3-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
> Set the init value before reset in probe function. And then just
> modify the relative bits and keep the init settings.

It breaks my old PCI Netgear 8110s (RTL_GIGA_MAC_VER_03/XID 04000000). Once
the device is up, RxConfig is changed from 0x0000e70e to 0x0000000e (missed
write ?).

Is there any side effect / objection if this patch is removed from the
series and scheduled for a later time ?

If the current working code is kept as is, the 8168c/cp would still see its
RxConfig:bit 13 (RxHalfRefetch) enabled.

-- 
Ueimor
