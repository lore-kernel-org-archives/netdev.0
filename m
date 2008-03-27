From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: net-2.6.26 compilation is still broken
Date: Thu, 27 Mar 2008 14:33:33 +0300
Message-ID: <1206617613.32459.3.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Dave!

Under 'make allyesconfig' net-2.6.26 on x86_64 compilation is broken
here:
artemis ~/src/linux-netns26 $ make O=all     
  Using /home/den/src/linux-netns26 as source for kernel
  GEN     /home/den/src/linux-netns26/all/Makefile
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    /home/den/src/linux-netns26/scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  LD      drivers/built-in.o
  LD      net/built-in.o
net/ieee80211/built-in.o: In function `ieee80211_get_channel':
/home/den/src/linux-netns26/net/ieee80211/ieee80211_geo.c:176: multiple
definition of `ieee80211_get_channel'
net/wireless/built-in.o:/home/den/src/linux-netns26/net/wireless/util.c:38: first defined here
ld: Warning: size of symbol `ieee80211_get_channel' changed from 98 in
net/wireless/built-in.o to 68 in net/ieee80211/built-in.o
net/ieee80211/built-in.o: In function `__crc_ieee80211_get_channel':
(*ABS*+0xa51295ec): multiple definition of `__crc_ieee80211_get_channel'
make[2]: *** [net/built-in.o] Error 1
make[1]: *** [net] Error 2
make: *** [sub-make] Error 2
artemis ~/src/linux-netns26 $

Regards,
	Den

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
