From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 00/15]bnx2x: add BCM57711 and new features
Date: Mon, 23 Jun 2008 19:01:21 +0300
Message-ID: <1214236882.3690.43.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Yitchak Gertner" <gertner@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Wendy Xiong" <wendyx@us.ibm.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1981 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754038AbYFWQBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 12:01:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is another attempt to send this patch with integrated comments.

This patch adds support for two new chips: BCM57711 and its variant the
BCM57711E, adds new link management code, new statistics code, enhanced
self-tests, IPv6 TSO and least but not last TPA, our hardware based LRO 
- I would like to thank Ben Hutchings for his comments on the LRO.

Wendy Xiong from IBM contributed the PCIE EEH handling code.

Patches:
01: Rename bnx2x.c to bnx2x_main.c - preparing to breakout the link code
    to a new file. This patch is a simple git mv bnx2x.c bnx2x_main.c
and
    the necessary Makefile change. Unfortunately, this patch is too big 
    for the mailing list so it contains only the Makefile diff and the 
    git mv command
02: Adding bnx2x_link - this part of the patch is just adding the new
    files (bnx2x_link.[ch]) without using them (to make the patch 
    smaller)
03. New link code - Major cleanup, using a separate file for link 
    related operations, smoother support of external PHY handling with 
    the device
04: New init infrastructure - support the new initialization for
    multi-chip environment, without the microcode
05: Remove old microcode - as part of the microcode replacement
06: New microcode part 1 - 1st part of the new microcode (BLOB)
07: New microcode part 2 - 2nd part of the new microcode (BLOB)
08: New microcode part 3 - 3rd part of the new microcode (BLOB)
09: Add support for BCM57711 HW, re-factoring struct bnx2x to allow this
10: New statistics code, fixes race between stats and close, add 
    BCM57711
11: Add TPA, Broadcom's HW LRO with ethtool support to allow turning
    off the feature when forwarding is enabled
12: Re-factor Tx code, add GSO_6 support
13. Enhanced self test
14: Add PCIE EEH support
15: Update version

Enjoy,
Eilon




