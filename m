From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 0/1 v2] skbuff: Extend gso_type to unsigned int
Date: Sat, 8 Apr 2017 20:36:23 +0200
Message-ID: <1491676584-22421-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46642 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752456AbdDHSgl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 14:36:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a GSO type for IPsec ESP to be able to integrate the IPsec
hardware offloading infrastructure. Unfortunately, all gso_type flags
are currently in use. This change extends gso_type from 'unsigned short'
to 'unsigned int'.

Changes from v1:

- Place the remaining two byte hole in front, suggested by
  Eric Dumazet.

- Skipping the memset of the two byte hole is unnecessary
  as it does not matter if we memset two or four bytes more,
  suggested by Alexander Duyck.
