From: David Dillow <dave@thedillows.org>
Subject: Re: r8169 NETDEV WATCHDOG: eth0: transmit timed out [0/8]
Date: Sat, 29 Aug 2009 09:39:40 -0400
Message-ID: <1251553180.13707.16.camel@obelisk.thedillows.org>
References: <b410963b0908290216x19206aa6o4458bb55b5578a04@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: roma1390 <roma1390@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:37956 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980AbZH2Njj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 09:39:39 -0400
In-Reply-To: <b410963b0908290216x19206aa6o4458bb55b5578a04@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-08-29 at 12:16 +0300, roma1390 wrote:
> Using 3 different r8169 devices on 2 servers (from 2 server so 100% of
> population) we getting
> 
> NETDEV WATCHDOG: eth0: transmit timed out

You're running an old version of the kernel, and the driver was patched
to fix that issue in 2.6.30. It is also in the 2.6.29.x stable series,
and I think maybe the 2.6.28.x series -- please try those and see if you
problem is resolved.

We're aware of a possible issue with the fix in those kernels, and are
working it in another thread. A quick search of the archives should turn
it up. Will you be willing to test patches?

>From your dmesg, it looks like you have 8169c's, running in MSI mode.
Can you please confirm this by sending your /proc/interrupt info:
	cat /proc/interrupts | grep eth0

Also, in the future, please cc netdev on network bug reports.
Thanks!

