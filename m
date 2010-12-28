From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Tue, 28 Dec 2010 04:37:00 +0000
Message-ID: <1293511020.2928.105.camel@localhost>
References: <20101227103247.8D2E813909@rere.qmqm.pl>
	 <alpine.LNX.2.00.1012271956260.8215@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: Hans Ulli Kroll <ulli.kroll@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46297 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab0L1EhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Dec 2010 23:37:08 -0500
In-Reply-To: <alpine.LNX.2.00.1012271956260.8215@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-27 at 20:21 +0100, Hans Ulli Kroll wrote:
[...]
> BTW:
> 
> Why u64_stats ?
> I see only a few driver are using u64_stats.
> vlan, br_device and some intel driver 
> no gigabit driver for marvell devices uses u64_stats

All new net drivers should implement 64-bit stats.  net_device_stats is
kept for backward compatibility because we couldn't change all the
existing drivers at once (it's not a simple change for all of them).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

