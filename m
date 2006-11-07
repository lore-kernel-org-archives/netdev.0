From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/3] NetXen: Fixed /sys mapping between device and driver
Date: Tue, 7 Nov 2006 08:38:31 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611070835060.26206@dut39>
References: <Pine.LNX.4.64.0611070818320.26206@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jeff@garzik.org, Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, wendyx@us.ibm.com,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:6415 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S932744AbWKGQih
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 11:38:37 -0500
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0611070818320.26206@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Amit S. Kale <amitkale@netxen.com>

  netxen_nic_main.c |    3 ++-
  1 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b54ea16..4effb87 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -270,6 +270,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
  		}

  		SET_MODULE_OWNER(netdev);
+		SET_NETDEV_DEV(netdev, &pdev->dev);

  		port = netdev_priv(netdev);
  		port->netdev = netdev;
@@ -1040,7 +1041,7 @@ static int netxen_nic_poll(struct net_de
  		netxen_nic_enable_int(adapter);
  	}

-	return (done ? 0 : 1);
+	return (!done);
  }

  #ifdef CONFIG_NET_POLL_CONTROLLER
