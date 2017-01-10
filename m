From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: dsa: Implement ndo_get_phys_port_name()
Date: Tue, 10 Jan 2017 12:32:35 -0800
Message-ID: <20170110203237.23907-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34104 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdAJUcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:32:47 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so9285475pfb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 12:32:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series implements ndo_get_phys_port_name() so we can revert
ndo_get_phys_id() which was (ab)used in the DSA layer.

Thanks

Florian Fainelli (2):
  net: dsa: Implement ndo_get_phys_port_name()
  Revert "net: dsa: Implement ndo_get_phys_port_id"

 net/dsa/slave.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
2.9.3
