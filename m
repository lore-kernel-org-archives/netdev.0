From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Thu, 17 Aug 2006 01:03:20 +0200
Message-ID: <200608170103.21097.arnd@arndb.de>
References: <44E34825.2020105@garzik.org> <200608162324.47235.arnd@arndb.de> <20060816225558.GM20551@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, akpm@osdl.org,
	jeff@garzik.org, netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:61660 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S932323AbWHPXDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 19:03:24 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060816225558.GM20551@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Thursday 17 August 2006 00:55 schrieb Linas Vepstas:
> > it only
> > seems to be hard to make it go fast using any of them.
>
> Last round of measurements seemed linear for packet sizes between
> 60 and 600 bytes, suggesting that the hardware can handle a
> maximum of 120K descriptors/second, independent of packet size.
> I don't know why this is.

Could well be related to latencies when going to the remote
node for descriptor DMAs. Have you tried if the hch's NUMA
patch or using numactl makes a difference here?

> > sounds like the right approach to simplify the code.
>
> Its not a big a driver. 'wc' says its 2.3 loc, which
> is 1/3 or 1/5 the size of tg3.c or the e1000*c files.

Right, I was thinking of removing a lock or another, not
throwing out half of the driver ;-)

	Arnd <><
