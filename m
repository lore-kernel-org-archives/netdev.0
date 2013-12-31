From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: mcs7830: rework link state detection
Date: Tue, 31 Dec 2013 16:54:10 -0500 (EST)
Message-ID: <20131231.165410.1591097579937834027.davem@davemloft.net>
References: <1387818391-12935-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	hunold@linuxtv.org, jeroen@koekkoek.nl, linux@rainbow-software.org,
	lkml20120218@newton.leun.net, ming.lei@canonical.com
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383Ab3LaVyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 16:54:12 -0500
In-Reply-To: <1387818391-12935-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Mon, 23 Dec 2013 19:06:31 +0200

> Even with the quirks in commit dabdaf0c (mcs7830: Fix link state
> detection) there are still spurious link-down events for some chips
> where the false link-down events count go over a few hundreds.
> 
> This patch takes a more conservative approach and only looks at
> link-down events where the link-down state is not combined with other
> states (e.g. half/full speed, pending frames in SRAM or TX status
> information valid). In all other cases we assume the link is up.
> 
> Tested on MCS7830CV-DA (USB ID 9710:7830).
> 
> Cc: Ondrej Zary <linux@rainbow-software.org>
> Cc: Michael Leun <lkml20120218@newton.leun.net>
> Cc: Ming Lei <ming.lei@canonical.com>
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>

Applied, thanks.
