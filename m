From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 0/2] net: dev_queue_xmit_nit fixes
Date: Tue,  8 Jan 2013 19:51:31 +0100
Message-ID: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641Ab3AHSvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 13:51:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch is a fix for the netdev discussion ``PROBLEM: Software injected
vlan tagged packets are unable to be identified using recent BPF
modifications'' and the second one I spotted while doing the first fix.

Daniel Borkmann (2):
  net: dev_queue_xmit_nit: fix skb->vlan_tci field value
  net: dev_queue_xmit_nit: fix potential NULL ptr dereference

 net/core/dev.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

-- 
1.7.11.7
