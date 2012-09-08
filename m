From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 0/2] iproute2: add GENL helpers
Date: Sat,  8 Sep 2012 12:48:23 +0300
Message-ID: <1347097705-2906-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47833 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800Ab2IHJpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 05:45:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Put common code for GENL users in new files.
I'll resend the tcp_metrics support for iproute2 when
the kernel part is in mainline.

Julian Anastasov (2):
  iproute2: add libgenl files
  iproute2: use libgenl in ipl2tp

 include/libgenl.h |   25 ++++++++++++++++++++
 ip/ipl2tp.c       |   65 ++--------------------------------------------------
 lib/Makefile      |    2 +-
 lib/libgenl.c     |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 94 insertions(+), 63 deletions(-)
 create mode 100644 include/libgenl.h
 create mode 100644 lib/libgenl.c

-- 
1.7.3.4
