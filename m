From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Thu, 16 Apr 2009 11:24:35 +0200
Message-ID: <20090416112435.0b779859@surf>
References: <20090415154658.40e3639a@surf>
	<20090416110753.5c75b805@hskinnemoen-d830>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Michael Opdenacker <michael@free-electrons.com>
To: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns6.enix.org ([193.19.211.1]:57254 "EHLO the-doors.enix.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754990AbZDPJxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 05:53:22 -0400
In-Reply-To: <20090416110753.5c75b805@hskinnemoen-d830>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thu, 16 Apr 2009 11:07:53 +0200,
Haavard Skinnemoen <haavard.skinnemoen@atmel.com> a =C3=A9crit :

> Hmm...is this safe? What if printk() is called from the macb interrup=
t
> handler?

I'm not sure, but that strategy is used in most drivers supporting the
netpoll API (3c509.c, 8139cp.c, 8139too.c, b44.c, bfin_mac.c,
bnx2x_main.c, etc.). It also seems to be the way suggested by netpoll
author, http://oss.sgi.com/archives/netdev/2003-10/msg00800.html.

disable_irq() only disables the macb IRQ line. Is that an issue for
printk() execution ?

Thomas
--=20
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
