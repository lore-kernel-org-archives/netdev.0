From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 0/1] NET: usb: cdc_mbim: add quirk for supporting Telit LE922A
Date: Wed,  7 Dec 2016 14:07:47 +0100
Message-ID: <1481116068-32691-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        Daniele Palmas <dnlplm@gmail.com>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
        Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32926 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbcLGNIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 08:08:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Telit LE922A MBIM based composition does not work properly
with altsetting toggle done in cdc_ncm_bind_common.

This patch adds CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE quirk
to avoid this procedure that, instead, is mandatory for
other modems.

References:
https://www.spinics.net/lists/linux-usb/msg149249.html
https://www.spinics.net/lists/linux-usb/msg149819.html

Thanks to Bjørn for the productive discussion and feedback!

Daniele Palmas (1):
  NET: usb: cdc_mbim: add quirk for supporting Telit LE922A

 drivers/net/usb/cdc_mbim.c  | 21 +++++++++++++++++++++
 drivers/net/usb/cdc_ncm.c   | 14 +++++++++-----
 include/linux/usb/cdc_ncm.h |  3 ++-
 3 files changed, 32 insertions(+), 6 deletions(-)

-- 
2.7.4
