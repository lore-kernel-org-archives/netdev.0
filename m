From: Rob Herring <robh@kernel.org>
Subject: [PATCH v3 0/4] TI Bluetooth serdev support
Date: Thu, 13 Apr 2017 10:03:49 -0500
Message-ID: <20170413150353.7389-1-robh@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Wei Xu <xuwei5@hisilicon.com>, Eyal Reizer <eyalr@ti.com>,
        Satish Patel <satish.patel@linaro.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34269 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754503AbdDMPED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 11:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds serdev support to the HCI LL protocol used on TI BT
modules and enables support on HiKey board with with the WL1835 module.
With this the custom TI UIM daemon and btattach are no longer needed.

The series is available on this git branch[1]. This version is rebased on 
bluetooth-next tree containing its dependencies.

Rob

[1] git://git.kernel.org/pub/scm/linux/kernel/git/robh/linux.git ti-bluetooth

Rob Herring (4):
  dt-bindings: net: Add TI WiLink shared transport binding
  bluetooth: hci_uart: remove unused hci_uart_init_tty
  bluetooth: hci_uart: add LL protocol serdev driver support
  arm64: dts: hikey: add WL1835 Bluetooth device node

 .../devicetree/bindings/net/ti,wilink-st.txt       |  35 +++
 arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts     |   5 +
 drivers/bluetooth/hci_ldisc.c                      |  19 --
 drivers/bluetooth/hci_ll.c                         | 262 ++++++++++++++++++++-
 drivers/bluetooth/hci_uart.h                       |   1 -
 5 files changed, 301 insertions(+), 21 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ti,wilink-st.txt

-- 
2.11.0
