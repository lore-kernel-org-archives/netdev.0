From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: phy and dsa random fixes/cleanups
Date: Tue, 20 Jan 2015 16:41:58 -0800
Message-ID: <1421800920-6281-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40425 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbAUAmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 19:42:20 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so49143518pab.0
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 16:42:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches were already present as part of my attempt to make
DSA modules work properly, these are the only two "valid" patches at
this point which should not need any further rework.

Thanks!

Florian Fainelli (2):
  net: phy: fixed: allow setting no update_link callback
  net: dsa: bcm_sf2: factor interrupt disabling in a function

 drivers/net/dsa/bcm_sf2.c   | 24 ++++++++++++------------
 drivers/net/phy/fixed_phy.c |  2 +-
 2 files changed, 13 insertions(+), 13 deletions(-)

-- 
2.1.0
