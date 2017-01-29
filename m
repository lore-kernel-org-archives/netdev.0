From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers 2017-01-29
Date: Sun, 29 Jan 2017 16:49:02 +0200
Message-ID: <87a8a9udk1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

small but important fixes for 4.10. Hopefully is the last pull request
for 4.10.

Please let me know if there are any problems.

Kalle

The following changes since commit 60f59ce0278557f7896d5158ae6d12a4855a72cc:

  rtlwifi: rtl_usb: Fix missing entry in USB driver's private data (2016-12=
-30 15:38:13 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git =
tags/wireless-drivers-for-davem-2017-01-29

for you to fetch changes up to 2b1d530cb3157f828fcaadd259613f59db3c6d1c:

  MAINTAINERS: ath9k-devel is closed (2017-01-28 09:15:50 +0200)

----------------------------------------------------------------
wireless-drivers fixes for 4.10

Most important here are fixes to two iwlwifi crashes, but there's also
a firmware naming fix for iwlwifi and a revert of an older bcma patch.

----------------------------------------------------------------
Jens Axboe (1):
      iwlwifi: fix kernel crash when unregistering thermal zone

Johannes Berg (1):
      iwlwifi: mvm: avoid crash on restart w/o reserved queues

J=C3=BCrg Billeter (1):
      iwlwifi: fix double hyphen in MODULE_FIRMWARE for 8000

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2017-01-23' of git://git.kernel.org/.../=
iwlwifi/iwlwifi-fixes
      MAINTAINERS: ath9k-devel is closed

Rafa=C5=82 Mi=C5=82ecki (1):
      Revert "bcma: init serial console directly from ChipCommon code"

 MAINTAINERS                                   |  1 -
 drivers/bcma/bcma_private.h                   |  3 +++
 drivers/bcma/driver_chipcommon.c              | 11 +++--------
 drivers/bcma/driver_mips.c                    |  3 +++
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c |  2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c  |  7 ++++---
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c   | 12 ++++++++----
 7 files changed, 22 insertions(+), 17 deletions(-)
