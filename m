From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v5 0/3] net/xen: Clean up
Date: Wed, 17 Jun 2015 12:38:20 +0100
Message-ID: <1434541103-31114-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The first 2 patches were originally part of the Xen 64KB series [1]. Although
I think they can go without waiting the rest of the 64KB series.

The third patch has been added in the v4.

Regards,

Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: netdev@vger.kernel.org

[1] http://lkml.org/lkml/2015/5/14/533

Julien Grall (3):
  net/xen-netfront: Correct printf format in xennet_get_responses
  net/xen-netback: Remove unused code in xenvif_rx_action
  net/xen-netback: Don't mix hexa and decimal with 0x in the printf
    format

 drivers/net/xen-netback/netback.c | 19 +++++++------------
 drivers/net/xen-netfront.c        |  2 +-
 2 files changed, 8 insertions(+), 13 deletions(-)

-- 
2.1.4
