From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [patch 0/6] 2.6.18: sb1250-mac: Driver model & phylib update
Date: Tue, 3 Oct 2006 16:17:57 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610021903490.1359@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:55566 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S964843AbWJCPR7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 11:17:59 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

 Here is a set of patches that update the sb1250-mac driver used for the 
onchip Gigabit Ethernet interfaces of the Broadcom SiByte family of SOCs 
including the BCM1250 and a couple of other members.  These are used, 
among others, on various Broadcom evaluation boards together with Broadcom 
Gigabit Ethernet PHY chips.  Changes include porting the driver to the 
driver model as a platform device, support for phylib, including the 
BCM54xx PHYs in the interrupt mode, proper resource managment and a couple 
of minor clean-ups.

 Apart from changes to networking code, there are a few required in the 
architecture-specific areas and therefore I am sending these changes to 
Ralf and the linux-mips list as well.  It might also involve a few more 
interested parties in the discussion.

 The changes were tested with a Broadcom SWARM board, which includes a 
BCM1250 part which has 3 MAC units on chip, of which 2 are usable, with 
BCM5421 PHY chips attached (both wired to the same interrupt line, which 
made testing whether IRQ sharing works properly in phylib possible).  
Link partners included a 1000base and a 100base interface doing 
autonegotiation as well as a 10base one doing none.

 Other Broadcom boards that I know of may have these or BCM5411 or BCM5461 
chips.  The lack of documentation or at least actual pieces of hardware 
makes the use of interrupts impossible for all but the SWARM, the Sentosa 
and the Shorty (with the latter unsupported by Linux).

  Maciej
