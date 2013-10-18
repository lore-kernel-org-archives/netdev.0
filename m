From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCH net-next 0/2] Removal of struct esp_data
Date: Fri, 18 Oct 2013 12:09:03 +0200
Message-ID: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
Cc: Mathias Krause <mathias.krause@secunet.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54001 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752497Ab3JRKJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 06:09:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series removes one level of indirection when accessing the aead
crypto algorithm in ESP transforms by simply removing struct esp_data.
This results in smaller code and less memory usage per xfrm state.

Please apply!

Mathias Krause (2):
  net: esp{4,6}: remove padlen from struct esp_data
  net: esp{4,6}: get rid of struct esp_data

 include/net/esp.h |   10 ----------
 net/ipv4/esp4.c   |   49 +++++++++++++++----------------------------------
 net/ipv6/esp6.c   |   48 +++++++++++++++---------------------------------
 3 files changed, 30 insertions(+), 77 deletions(-)

-- 
1.7.10.4
