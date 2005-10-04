From: Hal Rosenstock <halr@voltaire.com>
Subject: [PATCH] ipv4/fib_frontend.c: (Re)export
	ip_dev_find for 2.6.14
Date: 04 Oct 2005 11:01:14 -0400
Message-ID: <1128438073.4397.4105.camel@hal.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: netdev@vger.kernel.org
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

ipv4/fib_frontend.c: (Re)export ip_dev_find for 2.6.14

(There is emerging functionality (not yet pushed upstream) in the IB
subsystem which relies on this being available. ip_dev_find is used to
find a valid IPoIB device when the outgoing device returned by the route
lookup (ip_route_output_key) is using the loopback interface. A valid
IPoIB device is needed to perform sending an ARP and doing an IB path
lookup so that an IB connection can be made).

Signed-off-by: Hal Rosenstock <halr@voltaire.com>

--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -661,4 +661,5 @@ void __init ip_fib_init(void)
 }
 
 EXPORT_SYMBOL(inet_addr_type);
+EXPORT_SYMBOL(ip_dev_find);
 EXPORT_SYMBOL(ip_rt_ioctl);
