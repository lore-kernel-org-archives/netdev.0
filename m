From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net/wireless tree with the
 staging.current tree
Date: Fri, 30 Oct 2009 14:18:00 +1100
Message-ID: <20091030141800.eb72e320.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754455AbZJ3DSE@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got conflicts in
drivers/staging/rtl8187se/Kconfig and drivers/staging/rtl8192e/Kconfig
between commit a26961e914c88e3e2ed46ef67f83a33ad7b57c36 ("Staging: fix
wireless drivers depends") from the staging.current tree and commit
125b181aec7a67c71234284ecf6d9c729d05deda ("staging: Add proper selection
of WIRELESS_EXT and WEXT_PRIV") from the net/wireless tree.

Just context changes.  I fixed it up (see below) and can carry the fix
for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/staging/rtl8187se/Kconfig
index 203c79b,faf6c60..0000000
--- a/drivers/staging/rtl8187se/Kconfig
+++ b/drivers/staging/rtl8187se/Kconfig
@@@ -1,6 -1,7 +1,7 @@@
  config RTL8187SE
  	tristate "RealTek RTL8187SE Wireless LAN NIC driver"
 -	depends on PCI
 +	depends on PCI && WLAN
- 	depends on WIRELESS_EXT
+ 	select WIRELESS_EXT
+ 	select WEXT_PRIV
  	default N
  	---help---
diff --cc drivers/staging/rtl8192e/Kconfig
index 37e4fde,5c077b9..0000000
--- a/drivers/staging/rtl8192e/Kconfig
+++ b/drivers/staging/rtl8192e/Kconfig
@@@ -1,6 -1,7 +1,7 @@@
  config RTL8192E
  	tristate "RealTek RTL8192E Wireless LAN NIC driver"
 -	depends on PCI
 +	depends on PCI && WLAN
- 	depends on WIRELESS_EXT
+ 	select WIRELESS_EXT
+ 	select WEXT_PRIV
  	default N
  	---help---
