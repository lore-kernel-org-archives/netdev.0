From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: dsa: Mock-up driver couple fixes
Date: Wed,  5 Apr 2017 11:19:29 -0700
Message-ID: <20170405181931.8145-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, dan.carpenter@oracle.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32787 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932327AbdDESTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 14:19:43 -0400
Received: by mail-io0-f193.google.com with SMTP id f84so2145939ioj.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 11:19:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to Dan's static checker, a bunch of small issues were found in the code.

Florian Fainelli (2):
  net: dsa: loop: Fix uninitialized pvid variable
  net: dsa: loop: Initialize err in dsa_loop_vlan_dump

 drivers/net/dsa/dsa_loop.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
2.9.3
