From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/2] Remove MAC_FMT
Date: Fri, 15 Feb 2008 09:42:55 -0800
Message-ID: <1203097375.21308.20.camel@localhost>
References: <20080215104804.9870.15722.stgit@one>
	 <20080215.025855.202184003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080215.025855.202184003.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

MAC_FMT is no longer used

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index e157c13..7a1e011 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -130,7 +130,6 @@ extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
  *	Display a 6 byte device address (MAC) in a readable format.
  */
 extern char *print_mac(char *buf, const unsigned char *addr);
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_BUF_SIZE	18
 #define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
 
