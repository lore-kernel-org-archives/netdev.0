From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next 0/2] xen-netback: Changes around carrier handling
Date: Mon, 4 Aug 2014 16:20:56 +0100
Message-ID: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series starts using carrier off as a way to purge packets when the guest is
not able (or willing) to receive them. It is a much faster way to get rid of
packets waiting for an overwhelmed guest.
The first patch changes current netback code where it relies currently on
netif_carrier_ok.
The second turns off the carrier if the guest times out on a queue, and only
turn it on again if that queue (or queues) resurrects.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org 
