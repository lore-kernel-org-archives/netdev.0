From: David Miller <davem@davemloft.net>
Subject: AF_PACKET mmap() v4...
Date: Thu, 05 Nov 2015 00:04:14 -0500 (EST)
Message-ID: <20151105.000414.1682124328670738318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbbKEFEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 00:04:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As part of fixing y2038 problems, Arnd is going to have to make a new
version fo the AF_PACKET mmap() tpacker descriptors in order to extend
the time values to 64-bit.

So I want everyone to think about whether there are any other changes
we might want to make given that we have to make a v4 anyways.

Particularly, I am rather certain that the buffer management could be
improved.  Some have complained that v3 is kinda awkward to use and/or
suboptimal is various ways.

Thanks.
