From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/2] tun: linux socket filter support
Date: Sun, 14 Feb 2010 13:00:51 +0200
Message-ID: <20100214110051.GA30182__23541.6444404565$1266145556$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754023Ab0BNLFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Feb 2010 06:05:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun module already support RX filtering, however,
this is limited to filtering by mac address.
For virtio host, we also need filtering by vlan.

Rather than adding this directly, it seems cleaner
to add generic socket filter support.



Michael S. Tsirkin (2):
  net: export attach/detach filter routines
  tun: socket filter support

 drivers/net/tun.c      |   26 ++++++++++++++++++++++++++
 include/linux/if_tun.h |    3 +++
 net/core/filter.c      |    2 ++
 3 files changed, 31 insertions(+), 0 deletions(-)
