From: John Ogness <john.ogness@linutronix.de>
Subject: nonagle flags for TSQ
Date: Fri, 07 Feb 2014 16:08:39 +0100
Message-ID: <87fvnv2c5k.fsf@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:46174 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbaBGPIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 10:08:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This email is referring to your Linux patch
46d3ceabd8d98ed0ad10f20c595ca784e34786c5.

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=46d3ceabd8d98ed0ad10f20c595ca784e34786c5

I have a question about the use of tcp_write_xmit() in
net/ipv4/tcp_output.c

When tcp_write_xmit() is called, the nonagle flag of the tcp socket is
ignored and instead 0 is passed. This causes the Nagle-algorithm to be
used even if it should not be, which in some cases causes a large delay.

Was there a reason that 0 was hard-coded?

Although current mainline code has been refactored, 0 is still
hard-coded for TSQ cases.

John Ogness
