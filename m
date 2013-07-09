From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: add a new chip for RTL8411
Date: Wed, 10 Jul 2013 01:00:16 +0200
Message-ID: <20130709230015.GA6843@electric-eye.fr.zoreil.com>
References: <1373274541-1095-1-git-send-email-hayeswang@realtek.com>
 <20130709.125305.1668056299963467935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41795 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375Ab3GIXA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 19:00:27 -0400
Content-Disposition: inline
In-Reply-To: <20130709.125305.1668056299963467935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Francois, please review.

The style is consistent with the driver.

The commit message may state that this 8411 chipset does not require
any special action in rtl_link_chg_patch (whence differing from the
previous "F" 8411).

Most of the code shared by rtl_hw_start_8168g_2 and rtl_hw_start_8411_2
is already factored out. There is not much to win here.

The new RTL_GIGA_MAC_VER_XY id is added in the required places.

It builds.

It's fine.

-- 
Ueimor
