From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/1] af_iucv: Validate socket address length in iucv_sock_bind()
Date: Tue, 19 Jan 2016 10:41:32 +0100
Message-ID: <1453196493-57590-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp06.uk.ibm.com ([195.75.94.102]:52983 "EHLO
	e06smtp06.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757413AbcASJmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 04:42:06 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 19 Jan 2016 09:42:05 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

this patch fixes a problem reported by Dmitry Vyukov in december. It is built
and intended for the next-tree.

Thanks, Ursula

Ursula Braun (1):
  af_iucv: Validate socket address length in iucv_sock_bind()

 net/iucv/af_iucv.c | 3 +++
 1 file changed, 3 insertions(+)

-- 
2.3.9
