From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 0/1] skbuff: Extend gso_type to unsigned int
Date: Mon, 3 Apr 2017 10:15:51 +0200
Message-ID: <1491207352-27585-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50602 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751856AbdDCI1I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 04:27:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a GSO type for IPsec ESP to be able to integrate the IPsec
hardware offloading infrastructure. Unfortunately, all gso_type flags
are currently in use. This change extends gso_type from 'unsigned short'
to 'unsigned int'.

I'm sending this as a separate patch because it touches one of the
core networking structures, so I don't want to merge this together
with the IPsec hardware offloading infrastructure via the ipsec-next
tree.
