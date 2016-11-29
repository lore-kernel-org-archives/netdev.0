From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers 2016-11-29
Date: Tue, 29 Nov 2016 16:59:44 +0200
Message-ID: <87r35utjq7.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

if there's still time here's one more patch to 3.9. I think this is good
to have in 3.9 as it fixes an issue where we were printing uninitialised
memory in mwifiex. I had this in wireless-drivers already for some time
as I was waiting for other fixes and nothing serious actually came up.

If this doesn't make it to 3.9 that's not a problem, I'll just merge
this to wireless-drivers-next. Let me know what you prefer.

Kalle

The following changes since commit d3532ea6ce4ea501e421d130555e59edc2945f99:

  brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap (2016-10-27 18:04:54 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-11-29

for you to fetch changes up to fcd2042e8d36cf644bd2d69c26378d17158b17df:

  mwifiex: printk() overflow with 32-byte SSIDs (2016-11-17 13:16:52 +0200)

----------------------------------------------------------------
wireless-drivers fixes for 4.9

mwifiex

* properly terminate SSIDs so that uninitalised memory is not printed

----------------------------------------------------------------
Brian Norris (1):
      mwifiex: printk() overflow with 32-byte SSIDs

 drivers/net/wireless/marvell/mwifiex/cfg80211.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)
