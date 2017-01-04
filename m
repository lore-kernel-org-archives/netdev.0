From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: systemport: Fix padding vs. TSB insertion
Date: Tue,  3 Jan 2017 16:34:47 -0800
Message-ID: <20170104003449.27078-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36622 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760134AbdADAfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 19:35:40 -0500
Received: by mail-pg0-f65.google.com with SMTP id n5so35077285pgh.3
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 16:35:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series fixes how we pad the packets submitted to the SYSTEMPORT
adapter, and how the transmit status block (prepended 8 bytes) fits in the
picture. The first patch is not technically a bug fix, but is required for the
second path to be applied and to greatly simplify the skb length calculation.

Thanks and happy new year!

Florian Fainelli (2):
  net: systemport: Utilize skb_put_padto()
  net: systemport: Pad packet before inserting TSB

 drivers/net/ethernet/broadcom/bcmsysport.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

-- 
2.9.3
