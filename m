From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] tg3: Prevent spurious tx timeout by
 setting carrier off before tx disable.
Date: Wed, 14 Nov 2012 22:05:16 -0500 (EST)
Message-ID: <20121114.220516.343928647409738782.davem@davemloft.net>
References: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
	<1352940269-23821-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945909Ab2KODFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:05:17 -0500
In-Reply-To: <1352940269-23821-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 14 Nov 2012 16:44:27 -0800

> From: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> The watchdog will not trigger when the carrier is off when reconfiguring
> the device.  Because carrier state is now off during reset, we need to
> introduce a link_up flag to keep track of link state during PHY setup.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
