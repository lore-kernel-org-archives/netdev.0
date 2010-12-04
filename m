From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/2] Add and use vsprintf extension %pMbt for bluetooth macs
Date: Fri,  3 Dec 2010 18:33:02 -0800
Message-ID: <cover.1291419007.git.joe@perches.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Using vsprintf extensions can save text and data.
Add %pMbt for the byte reversed output for bluetooth addresses.

Joe Perches (2):
  vsprintf: Add %pMbt, bluetooth mac address
  bluetooth: Use printf extension %pMbt

 lib/vsprintf.c              |    6 +++++-
 net/bluetooth/bnep/core.c   |    3 +--
 net/bluetooth/cmtp/core.c   |    2 +-
 net/bluetooth/hci_conn.c    |    6 +++---
 net/bluetooth/hci_core.c    |    8 ++++----
 net/bluetooth/hci_event.c   |    6 +++---
 net/bluetooth/hci_sysfs.c   |   10 +++++-----
 net/bluetooth/hidp/core.c   |    4 ++--
 net/bluetooth/l2cap.c       |   19 +++++++++----------
 net/bluetooth/lib.c         |   14 --------------
 net/bluetooth/rfcomm/core.c |   16 ++++++++--------
 net/bluetooth/rfcomm/sock.c |    8 ++++----
 net/bluetooth/rfcomm/tty.c  |    6 +++---
 net/bluetooth/sco.c         |   12 ++++++------
 14 files changed, 54 insertions(+), 66 deletions(-)

-- 
1.7.3.2.245.g03276.dirty
