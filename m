From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: systemport: Add support for SYSTEMPORT lite
Date: Fri, 20 Jan 2017 11:08:25 -0800
Message-ID: <20170120190827.26444-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34057 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752590AbdATTId (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:08:33 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so5947250pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 11:08:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series adds support for SYSTEMPORT Lite which is an evolution
of the existing SYSTEMPORT adapter.

The two generations are largely identical as far as the transmit/receive
path are concerned, and there were just a few control path changes here
and there.

Thanks!

Florian Fainelli (2):
  net: systemport: Dynamically allocate number of TX rings
  net: systemport: Add support for SYSTEMPORT Lite

 .../devicetree/bindings/net/brcm,systemport.txt    |   5 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         | 334 +++++++++++++++++----
 drivers/net/ethernet/broadcom/bcmsysport.h         |  80 ++++-
 3 files changed, 339 insertions(+), 80 deletions(-)

-- 
2.11.0
