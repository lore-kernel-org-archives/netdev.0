From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Enable suspend when device is idle from boot.
Date: Sat, 31 Dec 2011 13:17:04 +0100
Message-ID: <20111231121704.GA9842@electric-eye.fr.zoreil.com>
References: <1325183594-8947-1-git-send-email-tbroch@chromium.org> <20111230.172211.188260740088628815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tbroch@chromium.org, nic_swsd@realtek.com, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47564 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938Ab1LaMZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2011 07:25:54 -0500
Content-Disposition: inline
In-Reply-To: <20111230.172211.188260740088628815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Francois, what would you like me to do with this patch?

I have not tested it yet. I have no objection if a fix must go in now.

There is a slot for some sanity testing this evening.

The description of the patch implies that the initial power management
state is not right. I would be more inclined to set it correctly when
the device goes up instead of checking repeatedly for a loss of sync
through rtl8169_runtime_idle. Todd, any comment ?

-- 
Ueimor
