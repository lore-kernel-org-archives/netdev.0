From: Antony Antony <antony@phenome.org>
Subject: [PATCH 0/2] add udp encapsulation port to xfrm_do_migrate
Date: Mon,  5 Jun 2017 23:56:23 +0200
Message-ID: <20170605215625.11043-1-antony@phenome.org>
Cc: Antony Antony <antony@phenome.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Richard Guy Briggs <rgb@tricolour.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud3.xs4all.net ([194.109.24.30]:53108 "EHLO
        lb3-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751309AbdFEV5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:57:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently xfrm_do_migrate only support migrating IP address.
This patches add UDP encapsulation port to xfrm_do_migrate.

The use case is for devices such as phones that support IKE MOBIKE.
Often when the device move from one network to the another or wake
up from sleep external NAT gateway IP address, port, or both could
change. With this patch xfrm_do_migrate will also support port change
if necessary.


Antony Antony (2):
  xfrm: extend MIGRATE with UDP encapsulation port
  xfrm: add UDP encapsulation port in migrate message

 include/net/xfrm.h     | 11 +++++++----
 net/key/af_key.c       |  5 +++--
 net/xfrm/xfrm_policy.c | 13 +++++--------
 net/xfrm/xfrm_state.c  | 23 ++++++++++++++++-------
 net/xfrm/xfrm_user.c   | 37 +++++++++++++++++++++++++++++--------
 5 files changed, 60 insertions(+), 29 deletions(-)

-- 
2.9.3
