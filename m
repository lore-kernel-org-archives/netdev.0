From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [GIT]: Networking
Date: Tue, 14 Jul 2009 20:31:23 +0100
Message-ID: <20090714203123.0ab1f7b8@lxorguk.ukuu.org.uk>
References: <20090714.122704.21107059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:51952 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755869AbZGNTad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:30:33 -0400
In-Reply-To: <20090714.122704.21107059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 8) Locking fix in TTY based networking drivers, from Ralf Baechle.

I thought we had established that this one was wrong following further
discussion. The tty drivers that were calling up from IRQ handlers have
been fixed by the cull of bogus tty->low_latency setting.
