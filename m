From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 unresolved symbol
Date: Tue, 15 Mar 2005 18:58:15 +0900 (JST)
Message-ID: <20050315.185815.12690947.yoshfuji@linux-ipv6.org>
References: <Pine.SOC.4.61.0503151136260.428@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: mroos@linux.ee, davem@davemloft.net
In-Reply-To: <Pine.SOC.4.61.0503151136260.428@math.ut.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.SOC.4.61.0503151136260.428@math.ut.ee> (at Tue, 15 Mar 2005 11:36:42 +0200 (EET)), Meelis Roos <mroos@linux.ee> says:

> This is todays 2.6.11+BK on x86 with modular ipv6:
> 
> WARNING: /lib/modules/2.6.11/kernel/net/ipv6/ipv6.ko needs unknown symbol dev_get_flags

Oops, thanks.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/core/dev.c 1.185 vs edited =====
--- 1.185/net/core/dev.c	2005-02-11 14:54:32 +09:00
+++ edited/net/core/dev.c	2005-03-15 18:47:34 +09:00
@@ -3328,6 +3328,7 @@
 EXPORT_SYMBOL(dev_change_flags);
 EXPORT_SYMBOL(dev_set_mtu);
 EXPORT_SYMBOL(dev_set_mac_address);
+EXPORT_SYMBOL(dev_get_flags);
 EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
