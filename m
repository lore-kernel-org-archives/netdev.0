From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] [PATCH net-2.6.24] Fix documentation for
	dev_put()/dev_hold()
Date: Tue, 18 Sep 2007 11:04:22 -0700
Message-ID: <adasl5bkfyx.fsf_-_@cisco.com>
References: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
	<adawsunkg8i.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: davem@davemloft.net
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adawsunkg8i.fsf@cisco.com> (Roland Dreier's message of "Tue,
	18 Sep 2007 10:58:37 -0700")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

It looks like the comments for dev_put() and dev_hold() got reversed somehow.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 include/linux/netdevice.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be5fe05..239ae68 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1030,7 +1030,7 @@ extern int		netdev_budget;
 extern void netdev_run_todo(void);
 
 /**
- *	dev_put - get reference to device
+ *	dev_put - release reference to device
  *	@dev: network device
  *
  * Hold reference to device to keep it from being freed.
@@ -1041,7 +1041,7 @@ static inline void dev_put(struct net_device *dev)
 }
 
 /**
- *	dev_hold - release reference to device
+ *	dev_hold - get reference to device
  *	@dev: network device
  *
  * Release reference to device to allow it to be freed.
