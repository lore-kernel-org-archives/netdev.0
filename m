From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Tue, 3 Apr 2007 22:57:44 +0200
Message-ID: <20070403205744.GB12969@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de
To: Christian Kujau <evil@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59316 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbXDCVAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 17:00:33 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Kujau <evil@g-house.de> :
[...]
> Please see http://nerdbynature.de/bits/2.6.20.4/ for details for both 
> hosts and feel free to ask for more details. Although both boxes are in 
> production we'll be happy test more bootoptions/patches and the like.

If the apic voodoo makes no difference, you can:
1 - leave it enabled
2 - check that netconsole is not used with the 8139 (it is busted)
3 - check that netconsole is not used at all
4 - try:
    http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc5/r8169-20070402

-- 
Ueimor
