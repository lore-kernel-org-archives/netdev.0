From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH 0/3] net: mvneta: fix usage as a module, and support QSGMII properly
Date: Tue, 15 Apr 2014 22:54:37 +0200
Message-ID: <87a9bmxqia.fsf@natisbad.org>
References: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	George Joseph <george.joseph@fairview5.com>,
	Willy Tarreau <w@1wt.eu>,
	Alexander Reuter <Alexander.Reuter@gmx.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:5401 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbaDOUy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2014 16:54:56 -0400
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp4-g21.free.fr (Postfix) with ESMTP id CB42E4C8078
	for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 22:54:53 +0200 (CEST)
In-Reply-To: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
	(Thomas Petazzoni's message of "Tue, 15 Apr 2014 15:50:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

Thomas Petazzoni <thomas.petazzoni@free-electrons.com> writes:

> This set of patches has been tested on:
>
>  * Armada XP GP (four QSGMII interfaces)
>  * Armada XP DB (two RGMII interfaces and two SGMII interfaces)
>  * Armada 370 Mirabox (two RGMII interfaces)
>
> I've tested both the driver built-in, and compiled as a module.
>
> Since the last attempt at fixing this was quite a fiasco, I'd like
> this new attempt to be tested more widely before being applied. I'll
> try to do some testing on other Armada boards I have, but independent
> testing from other persons would also be appreciated.
>
> Note that these patches apply after reverting the previous attempt,
> obviously.

I just tested the set w/ the driver built-on on top of current
3.15.0-rc1 w/ e3a8786c10e7 reverted on a RN102 (A370, 2xRGMII), a
RN104  (A370, 2xRGMII) and a RN2120 (AXP, 2xRGMII). The interface(s)
work(s) as expected, i.e. everything is in order. You can add my

Tested-by: Arnaud Ebalard <arno@natisbad.org>

Thanks for your work!

Cheers,

a+
