From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH v2 0/3] Series short description
Date: Thu, 30 Dec 2010 11:25:40 -0800
Message-ID: <20101230192449.21487.9764.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	lucy.liu@intel.com, shmulikr@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755041Ab0L3TaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 14:30:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 2 adds the recommended tlv attributes to the ets struct this will
be needed for offloaded LLDP engines. Host controlled LLDP agents will most
likely not use these fields.

Also Shmulik Ravid caught an error with a spin_lock on kmalloc failure.

---

John Fastabend (3):
      net_dcb: add application notifiers
      dcbnl: add appliction tlv handlers
      dcbnl: add support for ieee8021Qaz attributes


 include/linux/dcbnl.h  |  108 ++++++++++++++++++++
 include/net/dcbevent.h |   31 ++++++
 include/net/dcbnl.h    |   20 ++++
 net/dcb/Makefile       |    2 
 net/dcb/dcbevent.c     |   40 +++++++
 net/dcb/dcbnl.c        |  260 +++++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 453 insertions(+), 8 deletions(-)
 create mode 100644 include/net/dcbevent.h
 create mode 100644 net/dcb/dcbevent.c

-- 
Signature
