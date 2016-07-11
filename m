From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 0/2] net: ethoc: Error path and transmit fixes
Date: Mon, 11 Jul 2016 16:35:53 -0700
Message-ID: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jcmvbkbc@gmail.com, colin.king@canonical.com,
	tklauser@distanz.ch, thierry.reding@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36537 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbcGKXgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 19:36:00 -0400
Received: by mail-pa0-f67.google.com with SMTP id ib6so13521414pad.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 16:36:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series contains two patches for the ethoc driver while testing on a
TS-7300 board where ethoc is provided by an on-board FPGA.

First patch was cooked after chasing crashes with invalid resources passed to
the driver.

Second patch was cooked after seeing that an interface configured with IP
192.168.2.2 was sending ARP packets for 192.168.0.0, no wonder why it could not
work.

I don't have access to any other platform using an ethoc interface so
it could be good to some testing on Xtensa for instance.

Changes in v2, fixed the first commit message

Florian Fainelli (2):
  net: ethoc: Fix early error paths
  net: ethoc: Correctly pad short packets

 drivers/net/ethernet/ethoc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

-- 
2.7.4
