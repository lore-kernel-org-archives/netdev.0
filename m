From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Thu, 2 Apr 2009 10:11:02 +0100
Message-ID: <20090402091102.GJ4337@n2100.arm.linux.org.uk>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com> <37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com> <20090330143155.GA20101@pengutronix.de> <37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com> <20090331075951.GF22913@pengutronix.de> <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com> <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Carvalho de Assis <acassis@gmail.com>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: Sajith P V <sajithpv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:58506 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbZDBJLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:11:17 -0400
Content-Disposition: inline
In-Reply-To: <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 05:24:27PM +0530, Sajith P V wrote:
> cs89x0 media  IRQ 61, programmed I/O, MAC 00:00:00:00:00:00

Also note that this MAC address is invalid, so you'll need to use ifconfig
to set a valid MAC address before trying to bring the interface up.
