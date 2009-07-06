From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused by netem)
Date: Mon, 6 Jul 2009 19:26:43 +0200
Message-ID: <200907061926.43625.andres@anarazel.de>
References: <200907031326.21822.andres@anarazel.de> <20090706163106.GA4559@ami.dom.local> <a5d9929e0907061023g4306d80ewfc8907653b949005@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:56020 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091AbZGFR0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 13:26:42 -0400
In-Reply-To: <a5d9929e0907061023g4306d80ewfc8907653b949005@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 July 2009 19:23:18 Joao Correia wrote:
> Hello
>
> Since i already had the kernel compiled and ready to boot when i read
> this, i gave it a go anyway :-).
>
> I can reproduce the freeze with those 4 patches applied, so i can
> confirm that its, at least, related to, or exposed by, those patches.
> There must be something else too, or its just too much fuzziness, but
> the freeze takes a bit more time (approximately five minutes, give or
> take) compared to the instant freeze before, but its there with the
> patches, and without them, no freeze.
>
> I assume there isnt a "safe" way to get them out of current .31-rc's,
> right?
`echo 0 > /proc/sys/kernel/timer_migration` should mitigate the problem.

Andres
