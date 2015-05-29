From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 0/2] hv_netvsc: Implement NUMA aware memory allocation
Date: Thu, 28 May 2015 17:07:44 -0700
Message-ID: <1432858064-4627-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:37650
	"EHLO p3plsmtps2ded03.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbbE1Wqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 18:46:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate both receive buffer and send buffer from the NUMA node assigned to the
primary channel.

K. Y. Srinivasan (2):
  hv_netvsc: Allocate the receive buffer from the correct NUMA node
  hv_netvsc: Allocate the sendbuf in a NUMA aware way

 drivers/net/hyperv/netvsc.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

-- 
1.7.4.1
