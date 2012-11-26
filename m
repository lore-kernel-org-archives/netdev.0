From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH net-next:master 20/25] net/dsa: make DSA tagging depend on
 NETDEVICES and !S390
Date: Mon, 26 Nov 2012 10:50:30 -0800
Message-ID: <50B3B9F6.5060509@infradead.org>
References: <50b2f66a.czw+uqRm3Q/zfbER%fengguang.wu@intel.com> <CAKohpo=r2ZTp5uSp_5duc+zwWvkkwr8dMbz+Yn=WC+ngFy3-0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kbuild test robot <fengguang.wu@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33835 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527Ab2KZSu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 13:50:59 -0500
In-Reply-To: <CAKohpo=r2ZTp5uSp_5duc+zwWvkkwr8dMbz+Yn=WC+ngFy3-0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kconfig dependency warning by making DSA support depend on the
same kconfig symbols that NET_DSA depend on.

warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && NETDEVICES && !S390)

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 net/dsa/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20121126.orig/net/dsa/Kconfig
+++ linux-next-20121126/net/dsa/Kconfig
@@ -9,6 +9,7 @@ config NET_DSA
 
 
 menu "Distributed Switch Architecture support"
+	depends on NETDEVICES && !S390
 
 # tagging formats
 config NET_DSA_TAG_DSA
