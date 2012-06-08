From: David Miller <davem@davemloft.net>
Subject: netperf and endianness
Date: Thu, 07 Jun 2012 18:09:48 -0700 (PDT)
Message-ID: <20120607.180948.471478622905736125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759523Ab2FHBJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 21:09:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rick, I tried to use netperf between my x86-64 and sparc64 systems and
nothing works.

Does netperf do it's messaging in cpu byte order only?

I don't see anything in netperf-2.5.x that translates into and out of
network byte order :-/
