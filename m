From: Xo Wang <xow@google.com>
Subject: [PATCH 0/2] Broadcom BCM54612E support
Date: Fri, 21 Oct 2016 10:20:11 -0700
Message-ID: <1477070413-92621-1-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, openbmc@lists.ozlabs.org,
        joel@jms.id.au
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36365 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932490AbcJURUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 13:20:25 -0400
Received: by mail-pf0-f177.google.com with SMTP id e6so59967756pfk.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 10:20:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is based on tip of torvalds/master.

The first patch adds register definitions from Broadcom docs.

The second patch adds the BCM54612E PHY ID, flags, and device-specific
RGMII internal delay initialization.

I tested on a custom board with an Aspeed AST2500 SOC with its second
MAC connected to this PHY.

Xo Wang (2):
  net: phy: broadcom: Update Auxiliary Control Register
  net: phy: broadcom: Add support for BCM54612E
