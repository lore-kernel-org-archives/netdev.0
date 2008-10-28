From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Bugme-new] [Bug 11855] New: kernel BUG when bringing down ppp
 connection
Date: Tue, 28 Oct 2008 09:44:56 +0000
Message-ID: <20081028094456.2cfc32ac@lxorguk.ukuu.org.uk>
References: <bug-11855-10286@http.bugzilla.kernel.org/>
	<20081027202407.7e390191.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	bluesloth600@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:43261 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751099AbYJ1Jpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 05:45:52 -0400
In-Reply-To: <20081027202407.7e390191.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > kernel BUG at drivers/char/tty_ldisc.c:199!
> > invalid opcode: 0000 [1] PREEMPT SMP
> > CPU 1
> 
> This has an Alany feel to it?

Ldisc refcount went negative. Will take a look at the bug report when I
have time. First guess would be a bug in the specific USB serial driver -
so need to know which driver is handlign the 26-183 and what is loaded
(an lsmod would be handy)

Alan
