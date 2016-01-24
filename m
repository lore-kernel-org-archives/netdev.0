From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] net: fec: make driver endian-safe
Date: Sun, 24 Jan 2016 20:12:51 +0100
Message-ID: <1453662771.2390.0.camel@sipsolutions.net>
References: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
	 <1637940.UNKGUmXJxm@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Shawn Guo <shawnguo@kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55970 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbcAXTMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jan 2016 14:12:55 -0500
In-Reply-To: <1637940.UNKGUmXJxm@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-01-24 at 17:49 +0100, Arnd Bergmann wrote:

> I'd argue that the "(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)"
> is definitely wrong, because if we ever get another ARM platform
> that uses this driver, it may or may not work depending on whether
> the ARCH_MXC is also set, and that is not a helpful behavior.
> 
> Better make it simply CONFIG_ARM to keep the behavior independent
> of config options. It won't change anything for now but any future
> platform will probably work independent of configuration or would
> require a bugfix at all.
> 

I agree, but I'm not really sure it's in the scope of this particular
patch? Might be better to just have a separate patch with an
appropriate commit message changing this ifdef.

johannes
