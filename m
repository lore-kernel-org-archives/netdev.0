From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6) on
 Haswell hardware
Date: Sun, 5 Oct 2014 18:59:20 +0200
Message-ID: <20141005165920.GA21926@electric-eye.fr.zoreil.com>
References: <542B3829.3010108@crashplan.pro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Ceriel Jacobs <linux-ide@crashplan.pro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43747 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbaJEQ7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 12:59:32 -0400
Content-Disposition: inline
In-Reply-To: <542B3829.3010108@crashplan.pro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ceriel Jacobs <linux-ide@crashplan.pro> :
> With in-kernel r8169 module, only P-state package C3 (pc3) can be reached
> when enabling ASPM.
> 
> Only after installing r8168 driver (and enabling ASPM), a Haswell Celeron
> G1820/G1840 processer will enter package C6 state (pc6).

Vanilla kernel r8169 driver logs a message that contains an "XID" string.
Please grep for it in your dmesg so that I can narrow the search for 
meaningful differences in Realtek's r8168 driver.

Thanks.

-- 
Ueimor
