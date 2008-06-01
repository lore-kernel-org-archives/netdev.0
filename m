From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 0/13]bnx2x: add BCM57711 and new features
Date: Sun, 01 Jun 2008 11:11:49 -0400
Message-ID: <1212333109.6967.118.camel@ubuntu804desktop.localdomain>
References: <1211897738.6967.73.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Wendy Xiong" <wendyx@us.ibm.com>,
	"Eliezer Tamir" <eliezert@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2241 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbYFAPMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jun 2008 11:12:34 -0400
In-Reply-To: <1211897738.6967.73.camel@ubuntu804desktop.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-05-27 at 10:15 -0400, Eilon Greenstein wrote:
> Hi,
> 
> This update adds support for two new chips...
> Eilon

Hi,

              ---------------
I'm resending this patch with the following changes:
- Breaking the original first 3 patches into smaller chunks so all code
changes will find their way to the mailing list:
*** The first patch (git mv bnx2x.c bn2x_main.c) and the 5th patch
(microcode) are still too big, but they do not contain meaningful code
for review ***
- Adding comments for each patch
- Removing the CNIC patch
- Clearing the byte order marks before the "singed-off-by" in some
emails (noted by Ben Hutchings)
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
13: Update MAINTAINERS

Enjoy,
Eilon




