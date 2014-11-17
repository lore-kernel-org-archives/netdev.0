From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/4] igb: auxiliary PHC functions for the i210.
Date: Tue, 18 Nov 2014 00:06:21 +0100
Message-ID: <cover.1416265321.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>, <bruce.w.allan@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:53160 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbaKQXGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 18:06:30 -0500
Received: by mail-wi0-f178.google.com with SMTP id hi2so2180914wib.11
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 15:06:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds three features: time stamping external events,
producing a periodic output signal, and an internal PPS event. The
i210 PCIe card has a 6 pin header with SDP0-3, making it easy to try
out this new functionality.

An earlier version of this series was posted way back in May, 2013,
but that version lacked a good way to assign functions to the pins. In
the mean time, the PHC core has a standard method to configure the
pins, and this series makes use of it.

Thanks,
Richard

Richard Cochran (4):
  igb: refactor time sync interrupt handling
  igb: do not clobber the TSAUXC bits on reset.
  igb: enable internal PPS for the i210.
  igb: enable auxiliary PHC functions for the i210.

 drivers/net/ethernet/intel/igb/igb.h      |    9 ++
 drivers/net/ethernet/intel/igb/igb_main.c |  100 ++++++++----
 drivers/net/ethernet/intel/igb/igb_ptp.c  |  251 ++++++++++++++++++++++++++++-
 3 files changed, 326 insertions(+), 34 deletions(-)

-- 
1.7.10.4
