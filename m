From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 0/5] macsec: a few fixes
Date: Tue, 19 Apr 2016 19:36:37 +0200
Message-ID: <cover.1460967681.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209AbcDSRhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 13:37:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some small fixes for the macsec driver:
 - possible NULL pointer dereferences
 - netlink dumps fixes: RTNL locking, consistent dumps
 - a reference counting bug

Sabrina Dubroca (5):
  macsec: add missing NULL check after kmalloc
  macsec: take rtnl lock before for_each_netdev
  macsec: don't put a NULL rxsa
  macsec: fix rx_sa refcounting with decrypt callback
  macsec: add consistency check to netlink dumps

 drivers/net/macsec.c | 39 +++++++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 14 deletions(-)

-- 
2.8.0
