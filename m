From: Paul Jackson <pj@sgi.com>
Subject: Re: 2.6.7-rc2-mm1 - bk-netdev.patch e1000_ethtool.c doesn't build
Date: Wed, 2 Jun 2004 02:41:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602024118.40dc9359.pj@sgi.com>
References: <20040601021539.413a7ad7.akpm@osdl.org>
	<20040602022130.35a7571d.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Jackson <pj@sgi.com>
In-Reply-To: <20040602022130.35a7571d.pj@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> There may or may not be other errors past this ...

There are other errors - many more such duplicated and near-duplicated
lines, such as for one example the following.  Someone's shotgun
misfired and hit someone's foot.

@@ -1440,8 +1554,10 @@

 static void
 e1000_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+e1000_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;

 	switch(adapter->hw.device_id) {

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
