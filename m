From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH stable v2 0/3] virtio-net: backport error handling bugfix
Date: Thu, 26 Dec 2013 15:32:44 +0200
Message-ID: <1388064752-15734-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987Ab3LZN2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Dec 2013 08:28:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error handling for virtio-net mergeable buffers was broken
for a long time. Backport recent bugfix to a stable
kernel.

Please note that it's really a single change split out for ease of
review - that's why 2/2 is here even though it's not
stricktly a bugfix - the code becomes too confusing without it.

Please review and consider for stable.

Changes from v1:
	- include patch 3/3 as suggested by Michael
	- tweak commit log as suggested by Jason

Michael S. Tsirkin (3):
  virtio_net: fix error handling for mergeable buffers
  virtio-net: make all RX paths handle errors consistently
  virtio_net: don't leak memory or block when too many frags

 drivers/net/virtio_net.c | 103 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 73 insertions(+), 30 deletions(-)

-- 
MST
