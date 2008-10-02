From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCHv2 1/3] phylib: rename mii_bus::dev to mii_bus::parent
Date: Wed, 1 Oct 2008 22:11:23 -0500
Message-ID: <712CBC64-E0DD-4595-AFA0-9EFF5CA28C60@freescale.com>
References: <20081002014133.GB26575@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:63186 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbYJBDMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 23:12:08 -0400
In-Reply-To: <20081002014133.GB26575@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 1, 2008, at 20:41, Lennert Buytenhek wrote:

> In preparation of giving mii_bus objects a device tree presence of
> their own, rename struct mii_bus's ->dev argument to ->parent, since
> having a 'struct device *dev' that points to our parent device
> conflicts with introducing a 'struct device dev' representing our own
> device.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Acked-by: Andy Fleming <afleming@freescale.com>

