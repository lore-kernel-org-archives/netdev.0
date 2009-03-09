From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 0/3] bnx2x: net-2.6 Bug Fixes
Date: Mon, 09 Mar 2009 12:52:09 +0200
Message-ID: <1236595929.11030.11.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Alex Chiang" <achiang@hp.com>,
	"Bjorn Helgaas" <bjorn.helgaas@hp.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1828 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192AbZCIKxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 06:53:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series against net-2.6 contains critical bug fixes for the
bnx2x.

The first two issues manifest themselves on IA64 with 64KB pages and
were reported and tested by Bjorn Helgass <bjorn.helgass@hp.com>. Those
two do not exist in net-next. Please let me know if you want me to send
a patch against net-next with those fixes (or if you can apply it to
net-next as well).

The third and last issue was already fixed in net-next as part of an
enhancement. After implementing this enhancement we got reports on
failures on some specific boards only at first load after power up. It
turned out that the root-cause is a HW issue on those boards that needs
to be workaround with the usage of the DMAE to initialize the chip - so
we are back-porting the needed part out of the DMAE enhancement to
net-2.6 as well. This issue was also tested and verified by a costumer,
but I'm respecting that costumer privacy.

Please consider applying to net-2.6.

Thanks,
Eilon

Vlad - thanks for preparing this patch series!



