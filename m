From: "Sean Hefty" <sean.hefty@intel.com>
Subject: [PATCH 3/6] net/IB: export ip_dev_find
Date: Mon, 6 Mar 2006 11:07:44 -0800
Message-ID: <ORSMSX4011XvpFVjCRG00000006@orsmsx401.amr.corp.intel.com>
References: <adaslpz2l9p.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "'Roland Dreier'" <rdreier@cisco.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
In-Reply-To: <adaslpz2l9p.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Export ip_dev_find to allow locating a net_device given an IP address.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>

---

diff -uprN -X linux-2.6.git/Documentation/dontdiff 
linux-2.6.git/net/ipv4/fib_frontend.c 
linux-2.6.ib/net/ipv4/fib_frontend.c
--- linux-2.6.git/net/ipv4/fib_frontend.c	2006-01-16 10:28:29.000000000 -0800
+++ linux-2.6.ib/net/ipv4/fib_frontend.c	2006-01-16 16:14:24.000000000 -0800
@@ -666,4 +666,5 @@ void __init ip_fib_init(void)
 }
 
 EXPORT_SYMBOL(inet_addr_type);
+EXPORT_SYMBOL(ip_dev_find);
 EXPORT_SYMBOL(ip_rt_ioctl);
