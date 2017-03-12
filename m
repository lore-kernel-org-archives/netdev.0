From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 0/4] uapi glibc compat: fix musl libc compatibility
Date: Sun, 12 Mar 2017 23:00:35 +0100
Message-ID: <20170312220039.16885-1-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
        maillist-linux@barfooze.de, mikko.rapeli@iki.fi,
        Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code from libc-compat.h depends on some glibc specific defines and 
causes compile problems with the musl libc. These patches remove some 
of the glibc dependencies. With these patches the LEDE (OpenWrt) base 
user space applications can be build with unmodified kernel headers and 
musl libc.

This was compile tested with the user space from LEDE (OpenWrt) with 
musl 1.1.16, glibc 2.25 and uClibc-ng 1.0.22.

David Heidelberger (1):
  uapi/if_ether.h: prevent redefinition of struct ethhdr

Hauke Mehrtens (3):
  uapi glibc compat: add libc compat code when not build for kernel
  uapi glibc compat: fix build if libc defines IFF_ECHO
  uapi glibc compat: Do not check for __USE_MISC

 include/uapi/linux/if_ether.h    |  3 +++
 include/uapi/linux/libc-compat.h | 25 +++++++++++++++++++------
 2 files changed, 22 insertions(+), 6 deletions(-)

-- 
2.11.0
