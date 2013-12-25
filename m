From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH stable 0/2] virtio-net: backport error handling bugfix
Date: Wed, 25 Dec 2013 16:56:18 +0200
Message-ID: <1387983339-1172-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035Ab3LYOwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Dec 2013 09:52:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error handling for virtio-net mergeable buffers was broken
for a long time. Backport recent bugfix to a stable
kernel.

Please note that it's really a single patch split out in two for ease of
review: if we apply 1/2 only the code is correct but ugly and confusing, so I
think it's best to backport both patches 1/2 and 2/2 same as upstream has them.

Please review and consider for stable.

Michael S. Tsirkin (2):
  virtio_net: fix error handling for mergeable buffers
  virtio-net: make all RX paths handle erors consistently

 drivers/net/virtio_net.c | 103 ++++++++++++++++++++++++++++++++++-------------
 1 file changed, 74 insertions(+), 29 deletions(-)

-- 
MST
