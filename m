From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: encx24j600: Fix SPI driver module autoload
Date: Mon, 02 Nov 2015 15:33:21 -0500 (EST)
Message-ID: <20151102.153321.1233012842173794868.davem@davemloft.net>
References: <1446209358-26094-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: javier@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446209358-26094-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier@osg.samsung.com>
Date: Fri, 30 Oct 2015 13:49:16 +0100

> Recently I've been trying to fix module autoloading for all SPI drivers and
> found that the encx24j600 driver does not fill module alias information due
> missing a MODULE_DEVICE_TABLE() so module autload won't work and the driver
> Kconfig symbol is tristate which means the driver can be built as a module.
> 
> But also the SPI id table is not correctly defined so this series fixes both
> issues.

Series applied to net-next, thanks.
