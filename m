From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: bcmsysport: utilize newer NAPI APIs
Date: Wed, 20 Apr 2016 11:37:07 -0700
Message-ID: <1461177429-23553-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35374 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbcDTSjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 14:39:24 -0400
Received: by mail-pa0-f49.google.com with SMTP id fs9so20422245pac.2
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 11:39:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Eric, Petri,

These two patches are very analoguous to what was already submitted for
BCMGENET and switch the SYSTEMPORT driver to utilizing __napi_schedule_irqoff()
and napi_complete_done for the RX NAPI context.

Florian Fainelli (2):
  net: bcmsysport: use  __napi_schedule_irqoff()
  net: bcmsysport: use napi_complete_done()

 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
2.1.0
