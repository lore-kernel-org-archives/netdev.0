From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 0/2] fixes for net/sctp/auth.c
Date: Thu,  7 Feb 2013 11:55:35 +0100
Message-ID: <cover.1360231701.git.dborkman@redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757884Ab3BGKzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 05:55:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set fixes two issues in the net/sctp/auth.c implementation.

Daniel Borkmann (2):
  net: sctp: sctp_auth_make_key_vector: fix undefined ref-count behaviour
  net: sctp: sctp_auth_key_put: use kzfree instead of kfree

 net/sctp/auth.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

-- 
1.7.11.7
