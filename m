From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: ixgbe: panic in ixgbe_clean_rx_irq()
Date: Fri, 24 Jul 2009 10:41:50 +0200
Message-ID: <1248424910.17215.54.camel@localhost.localdomain>
References: <1248266678.17215.15.camel@localhost.localdomain>
	 <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>
	 <1248338779.17215.23.camel@localhost.localdomain>
	 <1248362493.17215.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:39436 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbZGXIlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 04:41:52 -0400
In-Reply-To: <1248362493.17215.45.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-23 at 17:21 +0200, Jesper Dangaard Brouer wrote:
> I'm going to run a test with a no-preempt kernel over night...

The no-preempt kernel has been stable for 17 hours, while running a four
times 10GbE pktgen load test (using 1024 bytes packets).

Kernel git version (git describe):
 v2.6.31-rc1-932-g8e321c4

Git ("git log e594e96..8e321c4 drivers/net/ixgbe") reports not changes
to the ixgbe driver between these two kernel versions.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

