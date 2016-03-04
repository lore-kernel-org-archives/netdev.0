From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers 2016-03-04
Date: Fri, 04 Mar 2016 18:26:38 +0200
Message-ID: <87lh5yw6o1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

three more fixes I would like to get to 4.5 still. It's getting late but
I think these are still justified and these have been in linux-next
almost a week. But if you think otherwise please let me know and I'll
pull these to wireless-drivers-next instead.

Kalle

The following changes since commit c699404db182836498bd9d9a36ef044de2cab4fd:

  Merge tag 'iwlwifi-for-kalle-2016-02-15' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-02-16 17:58:30 +0200)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-03-04

for you to fetch changes up to 10da848f67a7e7152bf7cbe332e4c92d71a990d2:

  ssb: host_soc depends on sprom (2016-02-26 12:47:32 +0200)

----------------------------------------------------------------
wireless-drivers fixes for 4.5

iwlwifi

* free firmware paging memory when the module is unloaded or device removed
* fix pending frames counter to fix an issue when removing stations

ssb

* fix a build problem related to ssb_fill_sprom_with_fallback()

----------------------------------------------------------------
Arnd Bergmann (1):
      ssb: host_soc depends on sprom

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-02-25' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Liad Kaufman (1):
      iwlwifi: mvm: inc pending frames counter also when txing non-sta

Matti Gottlieb (1):
      iwlwifi: mvm: Fix paging memory leak

 drivers/net/wireless/intel/iwlwifi/mvm/fw.c  |    4 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h |    3 +++
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c |    2 ++
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c  |    9 +++++++++
 drivers/ssb/Kconfig                          |    1 +
 5 files changed, 18 insertions(+), 1 deletion(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
