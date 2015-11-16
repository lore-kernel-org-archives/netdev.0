From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v2] dl2k: Add support for IP1000A-based cards
Date: Mon, 16 Nov 2015 17:11:56 -0500 (EST)
Message-ID: <20151116.171156.1040843400451886484.davem@davemloft.net>
References: <1447623372-29031-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbbKPWL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 17:11:58 -0500
In-Reply-To: <1447623372-29031-1-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sun, 15 Nov 2015 22:36:11 +0100

> Add support for IP1000A chips to dl2k driver.
> IP1000A chip looks like a TC9020 with integrated PHY.
> 
> This allows IP1000A chips to work reliably because the ipg driver is
> buggy - it loses packets under load and then completely stops
> transmitting data.
> 
> Tested with Asus NX1101 v2.0 at 10, 100 and 1000Mbps:
> vendor=0x13f0 device=0x1023 (rev 0x41)
> subsystem vendor=0x1043 device=0x8180
> 
> MAC address registers access needed to be changed from 8-bit to 16-bit
> because 8-bit does not work on IP1000A. 8-bit access is not even
> allowed in the TC9020 datasheet (although it worked). 16-bit access
> works on both.
> 
> Tested that it does not break D-Link DGE-550T (DL-2000 chip, probably
> a rebranded TC9020):
> vendor=0x1186 device=0x4000 (rev 0x0c)
> subsystem vendor=0x1186 device=0x4000
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Ok, this is a major step forward, thanks for doing this work.

Applied.
