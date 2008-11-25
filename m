From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH -next/-mm/mainline] net/hp-plus: fix link errors
Date: Tue, 25 Nov 2008 22:13:28 +0000
Message-ID: <20081125221328.6fc5a400@lxorguk.ukuu.org.uk>
References: <20081121.163335.255948683.davem@davemloft.net>
	<20081125095952.f25e8286.randy.dunlap@oracle.com>
	<20081125181800.7502d395@lxorguk.ukuu.org.uk>
	<20081125.134145.66227024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	akpm@linux-foundation.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:35372 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751007AbYKYWPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 17:15:38 -0500
In-Reply-To: <20081125.134145.66227024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We added code that splits the struct netdev function pointers out into
> a seperate structure.  In order to make initialization of the
> netdev_ops members work inside of the driver (and keep it const), we
> exported some of these 8390 library symbols.

Then probably they want __ sticking in front of them and wrapping in
8390.c and 8390p.c which is how the other symbols were done.

Alan
