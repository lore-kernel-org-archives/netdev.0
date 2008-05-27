From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 0/12]bnx2x: add BCM57711 and new features
Date: Tue, 27 May 2008 10:15:38 -0400
Message-ID: <1211897738.6967.73.camel@ubuntu804desktop.localdomain>
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
Received: from mms3.broadcom.com ([216.31.210.19]:3044 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754011AbYE0OQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 10:16:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This update adds support for two new chips: BCM57711 and its variant the
BCM57711E, adds new link management code, new statistics code, enhanced
self-tests, IPv6 TSO and least but not last TPA, our hardware based LRO.

Wendy Xiong from IBM contributed the PCIE EEH handling code.

I would like to thank Eliezer Tamir for writing and maintaining the
driver for the past two years. I will take over maintaining the bnx2x
driver from now on. 

Patches:
1: Renaming bnx2x.c to bnx2x_main.c - preparing to breakout the link
code to a new file. (this patch is a simple git mv bnx2x.c bnx2x_main.c
and the necessary Makefile change)
2: New link code - Major cleanup, move link to separate file, smother
support of external PHY handling with our device
3: New microcode
4: Add support for BCM57711 HW, re-factoring struct bnx2x to allow this
5: New statistics code, fixes race between stats and close, add BCM57711
6: Add TPA, Broadcom's HW LRO
7: Re-factor Tx code, add GSO_6 support
8. Enhanced self test
9: Add PCIE EEH support
10: Add CNIC support (needs Michael Chan's CNIC code to compile,
defaults to being defined out)
11: Update version
12: Update MAINTAINERS

Enjoy,
Eilon


