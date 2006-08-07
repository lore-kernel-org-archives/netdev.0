From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: tg3: tg3_stop_block timed out
Date: Tue, 08 Aug 2006 00:43:38 +0200
Message-ID: <eb8fmt$6lf$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:58048 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S932322AbWHGWuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 18:50:05 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GADv8-0002i4-JS
	for netdev@vger.kernel.org; Tue, 08 Aug 2006 00:50:02 +0200
Received: from c-134-176-179.d.dsl.de.ignite.net ([62.134.176.179])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 00:50:02 +0200
Received: from bernd-schubert by c-134-176-179.d.dsl.de.ignite.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 00:50:02 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have seen a few reports like this, but now broadcom seems to actively
support tg3, so I decided to send this.

... [many hamilton not responding messages]
4554928.798000] nfs: server hamilton not responding, still trying
[4554935.319000] nfs: server hamilton not responding, still trying
[4555468.940000] NETDEV WATCHDOG: eth1: transmit timed out
[4555468.940000] tg3: eth1: transmit timed out, resetting
[4555469.044000] tg3: tg3_stop_block timed out, ofs=3400 enable_bit=2
[4555469.147000] tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
[4555469.251000] tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
[4555469.354000] tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
[4555469.433000] tg3: eth1: Link is down.
[4555472.593000] tg3: eth1: Link is up at 1000 Mbps, full duplex.
[4555472.594000] tg3: eth1: Flow control is on for TX and on for RX.
[4555498.016000] nfs: server 129.206.21.200 OK
[4555648.015000] nfs: server 129.206.21.200 OK
... [many ok messages]

It seems to be the first time that something like this happend, at least I
don't find anything in the previous logs.

This is with 2.6.16, would it be worth to try a more recent tg3 driver (e.g.
from broadcom (3.58) or backported from 2.6.17 (3.59))? 


Thanks, 
Bernd




