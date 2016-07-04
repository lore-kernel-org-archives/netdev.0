From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/9] net: r6040: Misc updates
Date: Mon,  4 Jul 2016 14:36:00 -0700
Message-ID: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33880 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbcGDVgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:14 -0400
Received: by mail-oi0-f48.google.com with SMTP id s66so207167734oif.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are some various updates for the r6040 driver, mostly to make it more
modern and catch up with the latest API improvements.

Thanks!

Florian Fainelli (9):
  net: r6040: Utilize phy_print_status
  net: r6040: Increase statistics upon transmit completion
  net: r6040: Utilize skb_put_padto()
  net: r6040: Reclaim transmitted buffers in NAPI
  net: r6040: Check for skb->xmit_more
  net: r6040: Utilize __napi_schedule_irqoff
  net: r6040: Utilize napi_complete_done()
  net: r6040: Update my email
  net: r6040: Bump version and date

 MAINTAINERS                      |  2 +-
 drivers/net/ethernet/rdc/r6040.c | 59 ++++++++++++++++++----------------------
 2 files changed, 28 insertions(+), 33 deletions(-)

-- 
2.7.4
