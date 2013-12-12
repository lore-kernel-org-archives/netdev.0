From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next v2 0/2] ovs: introduce arch-specific fast hashing improvements
Date: Thu, 12 Dec 2013 16:09:04 +0100
Message-ID: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Daniel Borkmann <dborkman@redhat.com>
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab3LLPJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 10:09:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

We are introducing a fast hash function (see patch1) that can be
used in the context of OpenVSwitch to reduce the hashing footprint
(patch2). For details, please see individual patches!

Thanks !

v1->v2:
 - Make hash generic and place it under lib

Francesco Fusco (2):
  lib: introduce arch optimized hash library
  net: ovs: use CRC32 accelerated flow hash if available

 arch/x86/include/asm/hash.h  |  7 ++++
 arch/x86/lib/Makefile        |  2 +-
 arch/x86/lib/hash.c          | 88 ++++++++++++++++++++++++++++++++++++++++++++
 include/asm-generic/hash.h   |  9 +++++
 include/linux/hash.h         | 36 ++++++++++++++++++
 lib/Makefile                 |  2 +-
 lib/hash.c                   | 38 +++++++++++++++++++
 net/openvswitch/flow_table.c |  4 +-
 8 files changed, 182 insertions(+), 4 deletions(-)
 create mode 100644 arch/x86/include/asm/hash.h
 create mode 100644 arch/x86/lib/hash.c
 create mode 100644 include/asm-generic/hash.h
 create mode 100644 lib/hash.c

-- 
1.8.3.1
