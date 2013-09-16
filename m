From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 17:51:52 +0200
Message-ID: <20130916175152.4e013457@skate>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
	<20130915205701.5c61a444@skate>
	<20130916065047.GH27487@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ethan Tuttle <ethan@ethantuttle.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?UTF-8?B?Q2zDqW1l?= =?UTF-8?B?bnQ=?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56608 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750948Ab3IPPv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 11:51:59 -0400
In-Reply-To: <20130916065047.GH27487@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy, Ethan,

On Mon, 16 Sep 2013 08:50:47 +0200, Willy Tarreau wrote:

> I'm currently testing on 3.11.1 (which I had here) and am not getting
> any issue after 50M packets. My kernel is running in thumb mode and
> without SMP.
> 
> Ethan, we'll need your config I guess.

Can both of you also report the U-Boot version you're using, and the
SoC revision (it's visible in the U-Boot output). Maybe Globalscale is
shipping Mirabox with a different version of the bootloader, or some
hardware difference, that is causing problems? (I'm just speculating
here, but another user already reported having issues with his Mirabox,
and Russell King analyzed the oops as very likely being hardware
problems).

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
