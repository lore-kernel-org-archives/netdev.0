From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 0/8][BNX2X]: bugfixes and updates
Date: Wed, 20 Feb 2008 19:33:47 +0200
Message-ID: <1203528827.8232.85.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1756 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753123AbYBTRd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 12:33:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

This patch-set updates several sections of the bnx2x driver.

Patches 2-4 are a set that should not be applied partially.

1: fix spelling, some fashion policework, report PCI link

Spelling corrections, style fixes and properly report the PCI link speed
Many Thanks to Stephen Hemminger, that pointed out many of the
corrections.

2: update bootcode and link/phy code

The shared memory region used to talk to the bootcode has changed
** This is not backwards compatible and the older bootcode is no longer
supported **
** you will need to update the bootcode! **
This is the final version of the shared memory region that is supposed
to support upcoming chips as well.
This version also extends phy support.

3: Fix FW client config and assert printing

A rewrite of the code that configures rx filtering.
Some simple bug fixes to FW assert reporting.

4: rework slowpath and hw attentions

A rework of the slowpath code, fixes race when bringing down an
interface under traffic.

5: workaround for a PCI core bug

One of the internal queues can overflow when PCI max read request size
is big. This prevents the problem.


6: Xmit rework, add TSO6 and CSUM_HW support

Rework of the Xmit code, I hope that it is now clearer, this rework was
needed in order to add IPv6 CSUM and TSO.

7: update version to 1.42.2

8: add to MAINTAINERS
(So Michael stops getting complaints about my bugs)

Thanks
Eliezer



