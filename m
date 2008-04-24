From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Thu, 24 Apr 2008 21:44:57 +0100
Message-ID: <20080424214457.1d5a1655@the-village.bc.nu>
References: <m3r6cv75xq.fsf@maximus.localdomain>
	<20080424.063006.153647297.davem@davemloft.net>
	<m3mynj74nw.fsf@maximus.localdomain>
	<20080424.065555.30390704.davem@davemloft.net>
	<m3ve27nfpx.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	paulkf@microgate.com, jchapman@katalix.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:33265 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752925AbYDXVNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 17:13:54 -0400
In-Reply-To: <m3ve27nfpx.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think it's easier to a) simply remove syncppp.c, b) apply my patch
> with new PPP, c) blindly port the old drivers to generic HDLC,
> d) hope for the best, with a bit of luck nobody would notice.

I would agree with this. There isn't a sane way to sort out the old
kernel side syncppp (which is useless for todays networks as it doesn't
do compression, IPv6 or auth protocols) except by going to user space.
