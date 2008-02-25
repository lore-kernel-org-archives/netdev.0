From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH resend 2.6.25 0/12][BNX2X] bugfixes
Date: Mon, 25 Feb 2008 12:32:38 +0200
Message-ID: <1203935559.8232.204.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.31.210.20] ([216.31.210.20]:3568 "EHLO mms5.broadcom.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754491AbYBYKjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 05:39:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are just the bug fixes out of the previous update.
Please apply to 2.6.25

1  Spelling fixes

2  Fix bnx2x_init_one() - was printing wrong PCI-E info, failed to release netdev in one case.

3  Link mgmt and BC bugs - many link cfg fixes 
   The move to boot code 4.2.0 is mandatory since it fixes many bugs in the old ones.
   All old devices are being upgraded, all the devices that have been manufactured for a while have the new bootcode.
   (by the time 2.6.25 is out, there should no longer be any devices with pre-4.2.0 bootcode)

4  Correct rx filtering (AKA client-config)

5  Fix stats - rx errors were summed improperly, some were missing.

6  MSI-X / INT#A errata - loading with INT#A after using MSI-X did not work due to a HW bug.

7  HW attention and error handling - many fixes, sometimes improperly acked HW attentions could cause lockup.

8  Fixed slowpath races - fixed up/down racing with timer and fastpath.

9  Tx fixes - fix several bugs in start_xmit (the shiny new rewrite will wait for 2.6.26)

10 Update version

11 Add bnx2x to MAINTAINERS

Thanks
Eliezer


