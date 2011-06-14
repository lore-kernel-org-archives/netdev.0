From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Tue, 14 Jun 2011 14:32:31 +0300
Message-ID: <201106141432.32257.vladz@broadcom.com>
References: <201106141213.34576.vladz@broadcom.com>
 <BD3F7F1EFBA6D54DB056C4FFA451400809D2C13864@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"David Woodhouse" <dwmw2@infradead.org>
To: "Dave Miller" <davem@davemloft.net>,
	"Michael Chan" <mchan@broadcom.com>,
	"Bhanu (Venkata Bhanu Prakash) Gollapudi" <bprakash@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3785 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756231Ab1FNLdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:33:19 -0400
In-Reply-To: <BD3F7F1EFBA6D54DB056C4FFA451400809D2C13864@SJEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, pls., consider applying this patch series.

This patch series introduce support for the new 578x0 chip series and
therefore includes new 7.0.20 FW:
	1) New LINK code.
	2) Absolutely new HSI that allows supporting different chips in more
consolidated way, which caused a significant changes in the driver code
including moving the HSI handling code into a spearate files (patches 11
and 12).

We also send the new FW files to David Woodhouse. It's the first time we
submit to the linux-firmware git so I hope we don't mess the things up: we
DO NOT patch firmware/WHENCE and firmware/Makefile files in our net-next
patches and we patch the WHENCE file in the linux-firmware patch. Dave,
pls., confirm if it's a correct procedure.

If it is, pls., note that the bnx2x driver will compile but won't work
until u integrate the new FW into the kernel tree.

You may alsofind these patches at our public site.
	net-next series at http://linux.broadcom.com/eilong/1.70.00-0/
	New FW at http://linux.broadcom.com/eilong/FW-7.0.20.0/
 
Thanks,
vlad

