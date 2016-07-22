From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net 0/3] macsec: fix configurable ICV length
Date: Fri, 22 Jul 2016 15:07:55 +0200
Message-ID: <cover.1469191850.git.dcaratti@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444AbcGVNI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 09:08:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series provides a fix for macsec configurable ICV length. The 
maximum length of ICV element has been made compliant to IEEE 802.1AE,
and error reporting in case of cipher suite configuration failure has been
improved. Finally, a test has been added to netlink verify() callback in
order to avoid creation of macsec interfaces having user-provided ICV length
values that are not supported by the cipher suite.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Davide Caratti (3):
  macsec: limit ICV length to 16 octets
  macsec: fix error codes when a SA is created
  macsec: validate ICV length on link creation

 drivers/net/macsec.c           | 76 ++++++++++++++++++++++++++++--------------
 include/uapi/linux/if_macsec.h |  2 ++
 2 files changed, 53 insertions(+), 25 deletions(-)

-- 
2.5.5
