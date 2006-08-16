From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Thu, 17 Aug 2006 00:47:00 +0200
Message-ID: <200608170047.00811.arnd@arndb.de>
References: <200608162324.47235.arnd@arndb.de> <200608170016.47072.arnd@arndb.de> <20060816.152919.88472383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@osdl.org, jeff@garzik.org,
	netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:30195 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S932308AbWHPWrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 18:47:47 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060816.152919.88472383.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Thursday 17 August 2006 00:29 schrieb David Miller:
> Didn't you say spidernet's facilities were sophisticated? :)
> This Tigon3 stuff is like 5+ year old technology.

I was rather overwhelmed by the 34 different interrupts that
the chip can create, that does not mean they chose the right
events for generating them.
Interestingly, spidernet has five different counters you can
set up to generate interrupts after a number of received frames,
but none for transmit...

	Arnd <><
