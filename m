From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: incorrect args to oob notify
Date: Wed, 23 Feb 2011 21:00:28 +0100
Message-ID: <20110223200028.GA12784@electric-eye.fr.zoreil.com>
References: <20110223095237.0ee9c130@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45980 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243Ab1BWUEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 15:04:21 -0500
Content-Disposition: inline
In-Reply-To: <20110223095237.0ee9c130@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> :
[...]
> Sparse detected this bug. The function oob_notify was being
> passed the private ptr, but expected to get the ioaddr.
> Compile checked only; not tested on real hardware.
> 
> Patch against net-next-2.6 but should be applied to net-2.6.
> Bug not present in 2.6.37 and earlier.

Hayes has sent this fix and a few others. I am giving them a short
testing right now.

-- 
Ueimor
