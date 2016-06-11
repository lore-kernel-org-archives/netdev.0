From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Sat, 11 Jun 2016 10:42:26 -0700 (PDT)
Message-ID: <20160611.104226.1571085838142610714.davem@davemloft.net>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
	<20160610.225156.638004322598763463.davem@davemloft.net>
	<20160611153921.GP2338@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mario_limonciello@dell.com, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, pali.rohar@gmail.com,
	anthony.wong@canonical.com, gregkh@linuxfoundation.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbcFKRm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 13:42:29 -0400
In-Reply-To: <20160611153921.GP2338@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 11 Jun 2016 17:39:21 +0200

> What is still open is do we want to accept it at all? Do we accept the
> concept of putting the same MAC address on multiple interfaces at
> hotplug time? Do we trust BIOS vendors to not keep changing DSDT
> property name, since it is not standardised?
> 
> Do we want this at all should be decided by somebody more senior then
> those passing comments on the code.

Indeed, I think the behavior of using the same MAC address on multiple
interfaces if we plug several of these in at once is not good.

We shouldn't behave this way just because the Microsoft driver does.
