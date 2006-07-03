From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 9/15] pcmcia: hostap_cs.c - 0xc00f, 0x0000 conflicts
	with pcnet_cs
Date: Mon, 03 Jul 2006 12:57:09 -0400
Message-ID: <1151945829.26514.5.camel@dv>
References: <20060630195217.GB9095@dominikbrodowski.de>
	 <20060630195255.GC9095@dominikbrodowski.de>
	 <20060630195358.GD9095@dominikbrodowski.de>
	 <20060630195439.GE9095@dominikbrodowski.de>
	 <20060630195501.GF9095@dominikbrodowski.de>
	 <20060630195600.GG9095@dominikbrodowski.de>
	 <20060630195657.GH9095@dominikbrodowski.de>
	 <20060630195753.GI9095@dominikbrodowski.de>
	 <20060630195920.GJ9095@dominikbrodowski.de> <1151702323.21767.3.camel@dv>
	 <20060703085603.GA9465@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	hostap@shmoo.com, linville@tuxdriver.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:42113 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751158AbWGCQ51
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:57:27 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FxRjh-0004aZ-VL
	for netdev@vger.kernel.org; Mon, 03 Jul 2006 12:57:26 -0400
To: Dominik Brodowski <linux@dominikbrodowski.net>
In-Reply-To: <20060703085603.GA9465@dominikbrodowski.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

On Mon, 2006-07-03 at 10:56 +0200, Dominik Brodowski wrote:

> Like this?

Yes, but I usually drop revisions from the matched IDs, especially in
presence of the chip ID.  Why would we exclude "RevB" if it happens to
be ISL37300P based?  So the new entries would be:

	PCMCIA_DEVICE_PROD_ID123(
		"Allied Telesyn", "AT-WCL452 Wireless PCMCIA Radio",
		"Ver. 1.00",
		0x5cd01705, 0x4271660f, 0x9d08ee12),
	PCMCIA_DEVICE_PROD_ID123(
		"corega", "WL PCCL-11", "ISL37300P",
		0xa21501a, 0x59868926, 0xc9049a39),

-- 
Regards,
Pavel Roskin

