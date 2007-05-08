From: Michael Stone <mstone@mathom.us>
Subject: skge vs sk98lin
Date: Tue, 08 May 2007 08:00:36 -0400
Message-ID: <20070508120034.GB1785@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:39921 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967388AbXEHMAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 08:00:43 -0400
Received: from osgiliath.mathom.us ([72.66.113.156])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JHQ00AWZ1D6M7QL@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 08 May 2007 07:00:43 -0500 (CDT)
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.21 seems to have fixed the stability issues I was seeing when using 
the skge driver with the older sk98xx dual port fiber cards. There is 
still one more lingering oddness: if I have *two* dual port cards in a 
system, say eth2-5, I see traffic on eth2, eth3, and eth5, but nothing 
on eth4. This seems to be consistent accross a couple of systems I've 
tested; only the first card's second interface sees packets (e.g., with 
tcpdump). If I reboot with the sk98lin driver on the same kernel I see 
all traffic, as expected.

Mike Stone
