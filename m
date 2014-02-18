From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: remove unneeded dependency of mvneta and
 update help text
Date: Tue, 18 Feb 2014 13:45:32 +0100
Message-ID: <20140218134532.7607a616@skate>
References: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20140218122952.GM7862@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:44630 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754887AbaBRMpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 07:45:35 -0500
In-Reply-To: <20140218122952.GM7862@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jason Cooper,

On Tue, 18 Feb 2014 07:29:52 -0500, Jason Cooper wrote:

> >  config MVNETA
> > -	tristate "Marvell Armada 370/XP network interface support"
> > -	depends on MACH_ARMADA_370_XP
> 
> Have you build-tested this on the usual fail scenarios?  eg x86_64,
> powerpc, s390, allno, allyes, allmod, etc?
> 
> I think you might be opening up pandora's box here without needing to.
> :)

No, I haven't tested all the build scenarios of course. If you feel
that this is too dangerous, I can resend a patch that replaces 'depends
on ARMADA_370_XP' by 'depends on PLAT_ORION'. Would this be OK for you?

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
