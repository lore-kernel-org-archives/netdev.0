From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-11-06
Date: Thu, 06 Nov 2008 15:59:54 -0800 (PST)
Message-ID: <20081106.155954.52066801.davem@davemloft.net>
References: <20081106224904.GA30233@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752964AbYKFX7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 18:59:55 -0500
In-Reply-To: <20081106224904.GA30233@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 6 Nov 2008 17:49:04 -0500

> Here is the latest round of wireless bits intended for 2.6.28.  It
> includes a revert of an earlier fix that greatly reduced interrupts
> handled by ath5k -- testing showed that it resulted in a greater number
> of dropped associations.
> 
> Also included is an iwlwifi patch ("iwlwifi: clear scanning bits upon
> failure") that is already in -next.  It does not seem to be a strict
> regression, but since it is simple and can leave the device unable to
> scan (i.e. effectively inoperative) I think it is worth having now.
> There are also iwl3945 versions of some iwlwifi fixes as well as an
> iwl3945-specific one related to firmware errors.
> 
> Further, there is a WARN_ON fix for ath5k and another iwlwifi fix from
> me to avoid a possible sleep in softirq context.  Just for fun I've
> thrown-in a couple of zd1211rw USB ID additions as well.

Pulled, thanks a lot John.

> Please let me know if there are problems!  Any mistakes I blame on my
> recent bout of pneumonia...

Hope you feel better soon.
