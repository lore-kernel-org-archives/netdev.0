From: "Thomas A. Oehser" <tom@toms.net>
Subject: r8169 locks up in 2.6.16.5
Date: Sat, 15 Apr 2006 16:47:16 -0400
Message-ID: <20060415204716.GA1755@jupiter.toms.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.toms.net ([207.145.105.50]:17027 "EHLO jupiter.toms.net")
	by vger.kernel.org with ESMTP id S1751455AbWDOUrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2006 16:47:23 -0400
Received: from jupiter.toms.net (localhost [127.0.0.1])
	by jupiter.toms.net (8.12.10/8.12.10) with ESMTP id k3FKlHrj002164
	for <netdev@vger.kernel.org>; Sat, 15 Apr 2006 16:47:17 -0400
Received: (from tom@localhost)
	by jupiter.toms.net (8.12.10/8.12.10/Submit) id k3FKlG7e002163
	for netdev@vger.kernel.org; Sat, 15 Apr 2006 16:47:16 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

The r8169 driver seems not to be able to handle high loads?

On a dual Athlon 2600+ MP with 2GB RAM, and nothing else running.

I'm doing:

	nc -l -p 12345|buffer|cpio -iuvmdB

On the other machine, also with a gigabit card, I'm doing:

	find .|cpio -o -Hnewc -B|nc 192.168.111.1 12345

It works fine- for about 10 minutes- then, suddenly one of 3 things happens-
even if I stop the high-throughput transfer and quiescse everything.....

- Pings to the router take 9000ms instead of <1 ms (ifconfig down/up fixes it)
- or, it completely stops working, but ifconfig down/up makes it work again
- or, if iptables is natting, sometimes itg completely crashdump oopses

None of these problems occurs using the other NIC, an eepro100 or something.

Should I just give these cards away and forget I ever heard of RealTeK?

Is it known that this driver, or this card, or the comgination, is unstable?

Note, I have another machine using r8169, with some other OS- it doesn't fail.


-Tom

-- 
May 4, 1970: Alison Krause, Jeffrey Miller, Sandra Scheuer, William Schroeder.
