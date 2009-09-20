From: David Woodhouse <dwmw2@infradead.org>
Subject: [GIT *] Solos PCI ADSL driver update
Date: Sun, 20 Sep 2009 14:17:04 -0700
Message-ID: <1253481424.6317.203.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37090 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbZITVRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 17:17:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry, I suck. I forgot I had anything outstanding to be pushed
upstream, and should have done this a while ago.

In later versions of the card's FPGA code, the RAM layout for
card<->host communication has changed -- and the new FPGA code is in the
devices which are being shipped now, so it would be really useful if we
could sneak this into 2.6.32. Sorry it's so late.

Please pull from git://git.infradead.org/users/dwmw2/solos-2.6.git

David Woodhouse (1):
      solos: Add some margin-related parameters

Nathan Williams (2):
      solos: support new FPGA RAM layout
      solos: Check for rogue received packets

Simon Farnsworth (1):
      solos: Show Interleaving details for ADSL2 and 2+

 drivers/atm/solos-attrlist.c |   11 ++++++
 drivers/atm/solos-pci.c      |   75 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 77 insertions(+), 9 deletions(-)

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

