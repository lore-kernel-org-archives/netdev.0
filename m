From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 0/2] two small fixes for sctp key usage
Date: Fri,  8 Feb 2013 14:04:33 +0100
Message-ID: <cover.1360327229.git.dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946449Ab3BHNEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 08:04:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cryptographically used keys should be zeroed out when our session
ends resp. memory is freed, thus do not leave them somewhere in the
memory.

Daniel Borkmann (2):
  net: sctp: sctp_setsockopt_auth_key: use kzfree instead of kfree
  net: sctp: sctp_endpoint_free: zero out secret key data

 net/sctp/endpointola.c | 5 +++++
 net/sctp/socket.c      | 2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

-- 
1.7.11.7
