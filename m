From: Asias He <asias@redhat.com>
Subject: [PATCH 0/4] VSOCK fix and cleanup
Date: Thu, 20 Jun 2013 17:20:29 +0800
Message-ID: <1371720033-19714-1-git-send-email-asias@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>, Asias He <asias@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182Ab3FTJUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 05:20:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Asias He (4):
  VSOCK: Introduce vsock_auto_bind helper
  VSOCK: Return VMCI_ERROR_NO_MEM when fails to allocate skb
  VSOCK: Remove unnecessary label
  VSOCK: Fix VSOCK_HASH and VSOCK_CONN_HASH

 net/vmw_vsock/af_vsock.c       | 55 ++++++++++++++++++------------------------
 net/vmw_vsock/vmci_transport.c | 18 +++++++-------
 2 files changed, 33 insertions(+), 40 deletions(-)

-- 
1.8.1.4
