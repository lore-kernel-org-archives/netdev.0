From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [RFC/RFT PATCH 0/2 V2] Adding a new bluetooth driver to the kernel
Date: Mon,  8 Apr 2013 19:57:46 -0500
Message-ID: <1365469068-4548-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org,
	johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These patches supply the code needed to operate the bluetooth portion of
the Realtek RTL8723AE chip. Much of the necessary code is already present
in btusb, thus that driver is changed to export the necessary routines.
The second patch implements the routines that differ from the standard
driver.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>


Larry Finger (2):
  btusb: Modify code for use with a similar driver
  rtk_btusb: A new driver for the Bluetooth portion of the Realtek
    RTL8723AE chip

 drivers/bluetooth/Kconfig     |  10 +
 drivers/bluetooth/Makefile    |   1 +
 drivers/bluetooth/btusb.c     |  79 +---
 drivers/bluetooth/btusb.h     |  88 ++++
 drivers/bluetooth/rtk_btusb.c | 974 ++++++++++++++++++++++++++++++++++++++++++
 drivers/bluetooth/rtk_btusb.h | 102 +++++
 6 files changed, 1194 insertions(+), 60 deletions(-)
 create mode 100644 drivers/bluetooth/btusb.h
 create mode 100644 drivers/bluetooth/rtk_btusb.c
 create mode 100644 drivers/bluetooth/rtk_btusb.h

-- 
1.8.1.4
