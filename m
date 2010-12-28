From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Mon, 27 Dec 2010 21:12:22 -0800 (PST)
Message-ID: <1202721929.17594.1293513142947.JavaMail.root@tahiti.vyatta.com>
References: <1293511020.2928.105.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: =?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
	Hans Ulli Kroll <ulli.kroll@googlemail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45335 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718Ab0L1FMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Dec 2010 00:12:24 -0500
In-Reply-To: <1293511020.2928.105.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> On Mon, 2010-12-27 at 20:21 +0100, Hans Ulli Kroll wrote:
> [...]
> > BTW:
> >
> > Why u64_stats ?
> > I see only a few driver are using u64_stats.
> > vlan, br_device and some intel driver
> > no gigabit driver for marvell devices uses u64_stats
> 
> All new net drivers should implement 64-bit stats. net_device_stats is
> kept for backward compatibility because we couldn't change all the
> existing drivers at once (it's not a simple change for all of them).
> 
> Ben.

BS. drivers with old stats are fine. 64 bit only really matters
at higher speed. Anyway, it is the kind of thing that can easily
be fixed later after driver is merged.



