From: Joe Perches <joe@perches.com>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 23:38:17 -0700
Message-ID: <1309070297.23211.16.camel@Joe-Laptop>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <201106251803.53416.arnd@arndb.de>
	 <20110625161227.GJ23234@n2100.arm.linux.org.uk>
	 <201106251859.38963.arnd@arndb.de> <1309025217.2454.89.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sriram <srk@ti.com>, Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3210 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab1FZGiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jun 2011 02:38:19 -0400
In-Reply-To: <1309025217.2454.89.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-06-25 at 11:06 -0700, Jeff Kirsher wrote:
> On Sat, 2011-06-25 at 09:59 -0700, Arnd Bergmann wrote:
> > Jeff created a drivers/net/ethernet/8390/ directory for all of those,
> > which sounds sensible to me, but apparently he missed some of the
> > nonobvious ones.
> I was trying to keep the drivers that use the 8390 common files grouped
> together.

Please move a2065, ariadne and zorro8390 too.

> I know that there are other instances like this (for instance drivers
> derived from the lance.c driver) yet these derived drivers do not use
> the common files that other lance drivers use.  Because they are
> derived, yet do not use the common code, should they still be grouped
> together?

IMO, yes.

