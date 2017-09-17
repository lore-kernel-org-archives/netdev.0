From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 0/7] korina: performance fixes and cleanup
Date: Sun, 17 Sep 2017 20:23:53 +0300
Message-ID: <20170917172353.32225-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:48551 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751391AbdIQRYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:24:00 -0400
Received: by mail-lf0-f53.google.com with SMTP id q132so6022760lfe.5
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:23:59 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id l14sm1116913lfb.71.2017.09.17.10.23.56
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:23:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1:
- use GRO instead of increasing ring size
- use NAPI_POLL_WEIGHT instead of defining own NAPI_WEIGHT
- optimize rx descriptor flags processing

Roman Yeryomin (7):
  net: korina: don't use overflow and underflow interrupts
  net: korina: optimize rx descriptor flags processing
  net: korina: use NAPI_POLL_WEIGHT
  net: korina: use GRO
  net: korina: whitespace cleanup
  net: korina: update authors
  net: korina: bump version

 drivers/net/ethernet/korina.c | 230 ++++++++++++++----------------------------
 1 file changed, 78 insertions(+), 152 deletions(-)

-- 
2.11.0
