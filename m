From: Hans Ulli Kroll <ulli.kroll@googlemail.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Wed, 29 Dec 2010 17:56:58 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012291750060.9177@localhost>
References: <1202721929.17594.1293513142947.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
	Hans Ulli Kroll <ulli.kroll@googlemail.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46668 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828Ab0L2Q5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 11:57:06 -0500
Received: by eye27 with SMTP id 27so4642392eye.19
        for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 08:57:04 -0800 (PST)
In-Reply-To: <1202721929.17594.1293513142947.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 27 Dec 2010, Stephen Hemminger wrote:

> 
> 
> ----- Original Message -----
> > On Mon, 2010-12-27 at 20:21 +0100, Hans Ulli Kroll wrote:
> > [...]
> > > BTW:
> > >
> > > Why u64_stats ?
> > > I see only a few driver are using u64_stats.
> > > vlan, br_device and some intel driver
> > > no gigabit driver for marvell devices uses u64_stats
> > 
> > All new net drivers should implement 64-bit stats. net_device_stats is
> > kept for backward compatibility because we couldn't change all the
> > existing drivers at once (it's not a simple change for all of them).
> > 
> > Ben.
> 
> BS. drivers with old stats are fine. 64 bit only really matters
> at higher speed. Anyway, it is the kind of thing that can easily
> be fixed later after driver is merged.
> 
> 

I've readed the Intel driver.

So we must also implement to old net_stats interface, for backward 
compatibility ?

Ulli
