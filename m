From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/4] igb: auxiliary PHC functions for the i210.
Date: Mon, 27 May 2013 11:21:41 +0200
Message-ID: <cover.1369645944.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	<e1000-devel@lists.sourceforge.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:53958 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311Ab3E0JVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 05:21:52 -0400
Received: by mail-ea0-f181.google.com with SMTP id a11so3788354eae.40
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 02:21:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds three features: time stamping external events,
producing a periodic output signal, and an internal PPS event. The
i210 PCIe card has a 6 pin header with SDP0 and SDP1, making it easy
to try out this new functionality.

Thanks,
Richard

Richard Cochran (4):
  igb: refactor and simplify time sync interrupt handling
  igb: add more register definitions for time sync functions.
  igb: do not clobber the TSAUXC bits on reset.
  igb: enable auxiliary PHC functions for the i210.

 drivers/net/ethernet/intel/igb/e1000_defines.h |   68 +++++++++-
 drivers/net/ethernet/intel/igb/e1000_regs.h    |    9 ++
 drivers/net/ethernet/intel/igb/igb.h           |    2 +
 drivers/net/ethernet/intel/igb/igb_main.c      |   77 ++++++-----
 drivers/net/ethernet/intel/igb/igb_ptp.c       |  169 +++++++++++++++++++++++-
 5 files changed, 288 insertions(+), 37 deletions(-)

-- 
1.7.10.4
