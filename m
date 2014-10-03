From: Walter Lozano <walter@vanguardiasur.com.ar>
Subject: [PATCH net-next 0/2] Altera TSE with no PHY
Date: Fri,  3 Oct 2014 15:08:59 -0300
Message-ID: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Cc: davem@davemloft.net, tobias.klauser@gmail.com,
	vbridgers2013@gmail.com, f.fainelli@gmail.com,
	nios2-dev@lists.rocketboards.org, ezequiel@vanguardiasur.com.ar,
	guido@vanguardiasur.com.ar,
	Walter Lozano <walter@vanguardiasur.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:54336 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293AbaJCSKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 14:10:02 -0400
Received: by mail-qc0-f171.google.com with SMTP id i17so1423806qcy.2
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 11:10:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some scenarios there is no PHY chip present, for example in optical links.
This serie of patches moves PHY get addr and MDIO create to a new function and
avoids PHY and MDIO probing in these cases.

Walter Lozano (2):
  Altera TSE: Move PHY get addr and MDIO create
  Altera TSE: Add support for no PHY

 drivers/net/ethernet/altera/altera_tse_main.c |   65 +++++++++++++++++--------
 1 file changed, 44 insertions(+), 21 deletions(-)

-- 
1.7.10.4
