From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] arm: convert pcm037 platform to use smsc911x
Date: Tue, 20 Jan 2009 09:13:57 -0800 (PST)
Message-ID: <20090120.091357.93670796.davem@davemloft.net>
References: <1232458114-10997-3-git-send-email-steve.glendinning@smsc.com>
	<1232458114-10997-4-git-send-email-steve.glendinning@smsc.com>
	<20090120152951.GB21134@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, stanley.miao@windriver.com,
	ian.saturley@smsc.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38353
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759515AbZATRNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 12:13:55 -0500
In-Reply-To: <20090120152951.GB21134@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Tue, 20 Jan 2009 16:29:51 +0100

> I just gave it a try on our pcm037 board and it turns out that it
> doesn't work.
> 
> The reason for this is not the driver, it's just that the hardware
> designers got the direction of the phy detect pin wrong. The pcm037 uses
> an internal phy, but the detection pin is pulled high :(
> 
> The old driver worked around this by falling back to the internal phy
> when no valid phy id is detected. The new driver lacks this fallback.
> 
> Instead of falling back we could also introduce a
> SMSC911X_FORCE_INTERNAL_PHY flag.
> 
> What do you think?

You could pass this "invert detection pin" state in the platform
device private.
