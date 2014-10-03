From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: PHY state machine usage fix
Date: Thu,  2 Oct 2014 18:56:02 -0700
Message-ID: <1412301363-8478-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36779 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbaJCB4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 21:56:12 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so616959pab.16
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 18:56:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is a one-liner fixing long auto-negotiation with DSA devices, as I
mention in the commit message, the PHY state machine will need to be
fixed at some point to handle a phy_start_aneg() then phy_start() call,
but that looks too invasive for this merge window.

Thanks!

Florian Fainelli (1):
  net: dsa: do not call phy_start_aneg

 net/dsa/slave.c | 1 -
 1 file changed, 1 deletion(-)

-- 
1.9.1
