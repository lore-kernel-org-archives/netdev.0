From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net 0/3] net: phy: Finally fix PHY_IGNORE_INTERRUPTS
Date: Wed, 20 Jan 2016 21:20:16 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40499B30@CHN-SV-EXMX02.mchp-main.com>
References: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
 <20160119.143312.940032083335697894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <andrew@lunn.ch>,
	<sergei.shtylyov@cogentembedded.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:36815 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752164AbcATVUR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 16:20:17 -0500
In-Reply-To: <20160119.143312.940032083335697894.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Targetting the "net" tree since these are bugfixes, but I would like
> > Woojun and Andrew to take a look and test that on their respective
> > HW setups as well.
> 
> Ok I'll wait for Woojun and Andrew to give feedback.

This patch fixes periodic phy read_status access when phy is configured as PHY_IGNORE_INTERRUPTS.
Tested and confirmed with LAN78xx USB-to-Ethernet driver except following checkpatch.pl warnings.

WARNING: line over 80 characters
#54: FILE: drivers/net/phy/phy.c:1008:
+		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,

WARNING: Comparisons should place the constant on the right side of the test
#68: FILE: drivers/net/phy/phy.c:714:
+		if (PHY_HALTED != phydev->state &&
