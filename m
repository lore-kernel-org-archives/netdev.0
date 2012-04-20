From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3.4-rc 0/9] pch_gbe: ptp bug fixes
Date: Fri, 20 Apr 2012 22:09:19 +0200
Message-ID: <cover.1334949388.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63894 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab2DTUJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 16:09:46 -0400
Received: by wejx9 with SMTP id x9so6300952wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 13:09:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The content in this patch series originally was posted to netdev by
Takahiro on March 23, 2012, as a loose group of five patches. These
patches addressed problems pointed out in review, both on and off
list.

I have taken his work and rebased, squashed, and split it into the
present form, and I also wrote commit messages that more fully explain
the changes. Also, I added the last two patches myself.

Richard Cochran (2):
  pch_gbe: run the ptp bpf just once per packet
  pch_gbe: remove suspicious comment

Takahiro Shimizu (7):
  pch_gbe: scale time stamps to nanoseconds
  pch_gbe: simplify transmit time stamping flag test
  pch_gbe: reprogram multicast address register on reset
  pch_gbe: export a method to set the receive match address
  pch_gbe: improve coding style
  pch_gbe: do not set the channel control register
  pch_gbe: correct receive time stamp filtering

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    1 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |  107 +++++++++++++++-----
 drivers/ptp/Kconfig                                |   10 ++-
 drivers/ptp/ptp_pch.c                              |    7 +-
 4 files changed, 95 insertions(+), 30 deletions(-)

-- 
1.7.2.5
