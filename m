From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: systemport: interrupt coalescing support
Date: Mon, 11 May 2015 15:12:40 -0700
Message-ID: <1431382362-22332-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:32884 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbbEKWOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:14:34 -0400
Received: by pdbnk13 with SMTP id nk13so156706716pdb.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:14:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series adds support for RX & TX interrupt coalescing in the
systemport driver.

Florian Fainelli (2):
  net: systemport: Implement TX coalescing control knobs
  net: systemport: Implement RX coalescing control knobs

 drivers/net/ethernet/broadcom/bcmsysport.c | 63 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bcmsysport.h |  2 +-
 2 files changed, 64 insertions(+), 1 deletion(-)

-- 
2.1.0
