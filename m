From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 0/3] bonding: refuse to change bond type if it's
 used V3
Date: Wed, 10 Mar 2010 21:28:04 +0100
Message-ID: <20100310202804.GC2834@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593Ab0CJU2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 15:28:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2->v3:
-changed defines name to NETDEV_[PRE/POST]_TYPE_CHANGE
-added bits for vlan and macvlan

Reworked version of patch/patchset. This time I use netdevice notifier as
Stephen suggested. Changed the name of the original ones (NETDEV_BONDING_*TYPE)
to be more general and reused them.

Jirka
