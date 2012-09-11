From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2 0/2] iproute2: add GENL helpers
Date: Tue, 11 Sep 2012 12:04:32 +0300
Message-ID: <1347354274-3119-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53611 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644Ab2IKJAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 05:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Put common code for GENL users in new files.

v2:
- remove memset for buffer in GENL_INIT_REQUEST and use
C99 style initializers
- rename funcs: libgenl_ to genl_

Julian Anastasov (2):
  iproute2: add libgenl files
  iproute2: use libgenl in ipl2tp

 include/libgenl.h |   29 +++++++++++++++++++++++
 ip/ipl2tp.c       |   64 +--------------------------------------------------
 lib/Makefile      |    2 +-
 lib/libgenl.c     |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 97 insertions(+), 63 deletions(-)
 create mode 100644 include/libgenl.h
 create mode 100644 lib/libgenl.c

-- 
1.7.3.4
