From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/2] fix tiny races in MAC drivers
Date: Mon, 20 Jun 2011 09:48:05 +0200
Message-ID: <cover.1308555865.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41474 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab1FTHsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:48:01 -0400
Received: by fxm17 with SMTP id 17so759177fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:48:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In course of adding transmit time stamping, some unrelated problems
were uncovered. Drivers which free transmit buffers in an ISR must not
access the buffers after giving them to the hardware.

Richard Cochran (2):
  pxa168_eth: fix race in transmit path.
  mv643xx_eth: fix race in trasmit path.

 drivers/net/mv643xx_eth.c |    6 ++++--
 drivers/net/pxa168_eth.c  |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

