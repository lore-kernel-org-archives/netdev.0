From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 0/4] alx: add msi-x support
Date: Fri,  9 Sep 2016 12:19:51 +0200
Message-ID: <cover.1473404399.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, feng.tang@intel.com, jarod@redhat.com,
        Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34131 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753180AbcIIKUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 06:20:09 -0400
Received: by mail-wm0-f66.google.com with SMTP id w12so2048550wmf.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 03:20:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds msi-x support to the alx driver. It is a preparatory
series for multi queue support, which I am currently working on. As there
is no advantage over msi interrupts without multi queue support, msi-x
interrupts are disabled by default. In order to test for regressions, a
new module parameter is added to enable msi-x interrupts.

Based on information of the downstream driver at github.com/qca/alx

Tobias Regnery (4):
  alx: refactor msi enablement and disablement
  alx: factor out part of the interrupt handler
  alx: add msi-x support
  alx: add module parameter to enable msi-x support

 drivers/net/ethernet/atheros/alx/alx.h  |  10 +-
 drivers/net/ethernet/atheros/alx/hw.c   |  14 ++
 drivers/net/ethernet/atheros/alx/hw.h   |   1 +
 drivers/net/ethernet/atheros/alx/main.c | 235 ++++++++++++++++++++++++++++----
 4 files changed, 231 insertions(+), 29 deletions(-)

-- 
2.7.4
