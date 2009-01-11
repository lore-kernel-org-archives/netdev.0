From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Sun, 11 Jan 2009 16:56:02 +0000
Message-ID: <1231692963.25018.422.camel@macbook.infradead.org>
References: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
	 <20090109.140422.60087297.davem@davemloft.net>
	 <43805.1231672258@turing-police.cc.vt.edu>
	 <20090111.040842.86784676.davem@davemloft.net>
	 <1231676698.25018.147.camel@macbook.infradead.org>
	 <1231678799.25018.195.camel@macbook.infradead.org>
	 <58054.1231692502@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57448 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbZAKQ7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 11:59:45 -0500
In-Reply-To: <58054.1231692502@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-11 at 11:48 -0500, Valdis.Kletnieks@vt.edu wrote:
> One unanswered question:  What do we expect the system to do if they have this
> patch, TIGON3=y, FIRMWARE_IN_KERNEL=n, and configure a netconsole for boot
> messages?  I'm *hoping* the answer is "the netconsole doesn't come up at boot,
> but can be re-enabled via the /sys/kernel/config/netconsole interface after
> you've done an 'ifconfig eth0 up' or similar, or do a 'modprobe netconsole'.
> 
> Those seem like reasonable semantics to me - anybody got a different opinion?

If netconsole follows the normal ->open() path, that sounds like what'll
happen.

-- 
dwmw2

