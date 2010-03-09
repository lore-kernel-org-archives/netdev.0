From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 0/3] bonding: refuse to change bond type if it's
 used V2
Date: Tue, 9 Mar 2010 15:17:24 +0100
Message-ID: <20100309141724.GB2783@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab0CIOSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 09:18:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reworked version of patch/patchset. This time I use netdevice notifier as
Stephen suggested. Changed the name of the original ones (NETDEV_BONDING_*TYPE)
to be more general and reused them. Now the change is refused by brigde only.
I will follow up with vlan soon.

Jirka
