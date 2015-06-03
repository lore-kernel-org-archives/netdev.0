From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v2 0/2] net/xen: Clean up
Date: Wed, 3 Jun 2015 17:55:08 +0100
Message-ID: <1433350510-12846-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <stefano.stabellini@eu.citrix.com>,
	<linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Those 2 patches was originally part of the Xen 64KB series [1]. They are
already acked/reviewed and  can go in Linux via the net tree now
without waiting the rest of the series.

Sincerely yours,

Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: netdev@vger.kernel.org

[1] http://lkml.org/lkml/2015/5/14/533

Julien Grall (2):
  net/xen-netfront: Correct printf format in xennet_get_responses
  net/xen-netback: Remove unused code in xenvif_rx_action

 drivers/net/xen-netback/netback.c | 5 -----
 drivers/net/xen-netfront.c        | 2 +-
 2 files changed, 1 insertion(+), 6 deletions(-)

-- 
2.1.4
