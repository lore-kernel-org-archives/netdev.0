From: "Barak Witkowski" <barak@broadcom.com>
Subject: [PATCH net-next 0/3] bnx2x: use FW 7.2.51 and add afex support
Date: Mon, 23 Apr 2012 16:04:33 +0300
Message-ID: <1335186273.14229.25.camel@lb-tlvb-barak.il.broadcom.com>
Reply-To: barak@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4268 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab2DWNJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 09:09:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch utilize FW 7.2.51 that was recently added to the linux-firmware tree.

The main feature of this new FW is support of the AFEX multi-function protocol.
Supporting the afex protocol requires many changes in the driver, but all of
them are required together in order to compile and make the feature operational.
Breaking the afex patch into smaller chunks did not seem to increase readability
to me.

Thanks,
Barak
