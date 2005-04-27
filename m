From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.4 8/16] e1000: Fix computation of netdev
 stats from controller stats counters (fwd)
Date: Wed, 27 Apr 2005 11:06:49 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271106130.17397-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix computation of netdev stats from controller stats counters - from
sfeldma@pobox.com

Signed-off-by: Mallikarjuna R Chilakala
<mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c
net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c      2005-04-12
23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c  2005-04-12
23:00:55.000000000 -0700
@@ -2187,9 +2187,9 @@ e1000_update_stats(struct e1000_adapter

        adapter->net_stats.rx_errors = adapter->stats.rxerrc +
                adapter->stats.crcerrs + adapter->stats.algnerrc +
-               adapter->stats.rlec + adapter->stats.rnbc +
-               adapter->stats.mpc + adapter->stats.cexterr;
-       adapter->net_stats.rx_dropped = adapter->stats.rnbc;
+               adapter->stats.rlec + adapter->stats.mpc +
+               adapter->stats.cexterr;
+       adapter->net_stats.rx_dropped = adapter->stats.mpc;
        adapter->net_stats.rx_length_errors = adapter->stats.rlec;
        adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
        adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
