From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 00/12]bnx2x: add BCM57711 and new features
Date: Tue, 17 Jun 2008 11:32:09 +0300
Message-ID: <1213691529.5817.59.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Wendy Xiong" <wendyx@us.ibm.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Jeff Garzik" <jeff@garzik.org>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1491 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163AbYFQIc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 04:32:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

              ---------------
This is a re-send of the patch from June 1st with the following changes:
- changing this email (00/12) to indicate that this is a re-send
- Adding a missing signed off by Yaniv Rosner to patch 02/12
- Removing the last patch "Update MAINTAINERS" since it was already
  applied on the net-2.6

Please note that the first patch (git mv bnx2x.c bn2x_main.c) and the
5th patch (microcode) are too big for the mailing list, but they do not
contain meaningful code for review - Dave, I hope you will get them
without any problems.
              ---------------

This update adds support for two new chips: BCM57711 and its variant the
BCM57711E, adds new link management code, new statistics code, enhanced
self-tests, IPv6 TSO and least but not last TPA, our hardware based LRO.

Wendy Xiong from IBM contributed the PCIE EEH handling code.

I would like to thank Eliezer Tamir for writing and maintaining the
driver for the past two years. I will take over maintaining the bnx2x
driver from now on. 

Patches:
1: Rename bnx2x.c to bnx2x_main.c - preparing to breakout the link code
to a new file. This patch is a simple git mv bnx2x.c bnx2x_main.c and
the necessary Makefile change. Unfortunately, this patch is too big for
the mailing list, but it does not contain meaningful code changes
2: Adding bnx2x_link - this part of the patch is just adding the new
files (bnx2x_link.[ch]) without using them (to make the patch smaller)
3. New link code - Major cleanup, using a separate file for link related
operations, smoother support of external PHY handling with our device
4: New init infrastructure - support the new initialization for
multi-chip environment, without the microcode
5: New microcode - this patch is just the microcode (no code changes).
Unfortunately, this patch is too big for the mailing list, but it does
not contain meaningful code changes
6: Add support for BCM57711 HW, re-factoring struct bnx2x to allow this
7: New statistics code, fixes race between stats and close, add BCM57711
8: Add TPA, Broadcom's HW LRO
9: Re-factor Tx code, add GSO_6 support
10. Enhanced self test
11: Add PCIE EEH support
12: Update version
-removed 13: Update MAINTAINERS-

Enjoy,
Eilon




