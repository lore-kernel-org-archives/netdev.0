From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: added support for 40GbE link.
Date: Tue, 19 Jun 2012 00:35:17 -0700 (PDT)
Message-ID: <20120619.003517.2067426285873138772.davem@davemloft.net>
References: <1340039376.2913.13.camel@bwh-desktop.uk.solarflarecom.com>
	<20120619.002905.922583388766089167.davem@davemloft.net>
	<5D6C0ABE6A236946864C45679362BBE20AC52269@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: Parav.Pandit@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab2FSHfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 03:35:17 -0400
In-Reply-To: <5D6C0ABE6A236946864C45679362BBE20AC52269@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Parav.Pandit@Emulex.Com>
Date: Tue, 19 Jun 2012 07:33:12 +0000

> Should eventually all net driver should remove using SPEED_xxxxxx and start using hard coded value of 10, 100, 1000, 20000?

No, the ones that exist can stay, just no new ones.

> That means ethtool_cmd_speed() should not be called in this function?

Ben said that it must be called, what are you talking about?
