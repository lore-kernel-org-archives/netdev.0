From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [v3 net-next PATCH 0/3] Energy Efficient Ethernet (eee) support
Date: Wed, 6 Jun 2012 22:07:20 +0300
Message-ID: <1339009643-22951-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2767 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757653Ab2FFTJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 15:09:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series adds energy efficient ethernet support for the
bnx2x driver (for new chips with appropriate phys). 
It also extends the ethtool API to enable control of the eee feature.

Another patch series has been sent to Ben to allow the ethtool application
to use this new API.

Changes from Version 2:
	Patch 1/3:
		-Corrected ethtool_eee documentation in ethtool.h.

Changes from Version 1:
	Patch 1/3:
		-Added documentation to ethtool_eee struct in header.
		-Clearing the ethtool_eee struct before passing to driver.
		-Checking the driver's return value of 'get_eee' call.
	Patches 2-3/3:
		-Corrected conversion of tx_lpi_timer speeds in bnx2x.

Please consider applying it to 'net-next'.

Thanks,
Yuval Mintz
