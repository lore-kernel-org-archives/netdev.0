From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/4] [NET] Distributed Switch Architecture protocol support
Date: Thu, 25 Sep 2008 18:52:16 +0200
Message-ID: <20080925165216.GA25461@xi.wantstofly.org>
References: <20080925163845.GB25190@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:37481 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbYIYQwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 12:52:18 -0400
Content-Disposition: inline
In-Reply-To: <20080925163845.GB25190@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 06:38:45PM +0200, Lennert Buytenhek wrote:

> +#define to_mii_bus(d) container_of(d, struct mii_bus, dev)

I just realised that this patch depends on a phylib patch in my
tree (which I haven't submitted yet) which gives struct mii_bus a
struct device and hooks it up into the device tree, so that the
DSA driver can find the mii_bus given a struct device for it.
Please ignore this bit for now.
