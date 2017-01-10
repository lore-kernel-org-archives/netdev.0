From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-01-10
Date: Tue, 10 Jan 2017 08:18:40 +0200
Message-ID: <87a8aztp33.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's the pull request with the important rtlwifi fix, more info in the
tag below.

During the long weekend we had here I finally updated Ubuntu on my
workstation and git was updated along that. If you see anything funny or
problems in my pull request due to the upgrade, please let me know. The
upgrade might have broken something, at least git-request-pull needs to
be now called differently.

Kalle

The following changes since commit f5a0aab84b74de68523599817569c057c7ac1622:

  net: ipv4: dst for local input routes should use l3mdev if relevant (2016-12-29 22:27:23 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-01-10

for you to fetch changes up to 60f59ce0278557f7896d5158ae6d12a4855a72cc:

  rtlwifi: rtl_usb: Fix missing entry in USB driver's private data (2016-12-30 15:38:13 +0200)

----------------------------------------------------------------
wireless-drivers fixes for 4.10

Only two fixes at this time. The rtlwifi fix is an important one as it
fixes a reported oops and Linus was already asking about it. The
orinoco fix is not tested on a real device, because it's old legacy
hardware and hardly no-one use it, but it should fix a (theoretical)
issue with VMAP_STACK.

----------------------------------------------------------------
Andrew Lutomirski (1):
      orinoco: Use shash instead of ahash for MIC calculations

Larry Finger (1):
      rtlwifi: rtl_usb: Fix missing entry in USB driver's private data

 drivers/net/wireless/intersil/orinoco/mic.c     | 44 +++++++++++++++----------
 drivers/net/wireless/intersil/orinoco/mic.h     |  3 +-
 drivers/net/wireless/intersil/orinoco/orinoco.h |  4 +--
 drivers/net/wireless/realtek/rtlwifi/usb.c      |  1 +
 4 files changed, 31 insertions(+), 21 deletions(-)
