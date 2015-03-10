From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-03-10
Date: Tue, 10 Mar 2015 16:05:26 +0200
Message-ID: <87y4n5x80p.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51123 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbbCJOFd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 10:05:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is wireless-drivers pull request for 4.0, changelog below. Please
let me know if there are any problems.

Kalle


The following changes since commit acf8dd0a9d0b9e4cdb597c2f74802f79c699=
e802:

  udp: only allow UFO for packets from SOCK_DGRAM sockets (2015-03-02 2=
2:19:29 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.=
git tags/wireless-drivers-for-davem-2015-03-10

for you to fetch changes up to 3f1615340acea54e21f4b9d4d65921540dca84b2=
:

  brcmfmac: Perform bound checking on vendor command buffer (2015-03-07=
 10:52:30 +0200)

----------------------------------------------------------------
iwlwifi:

* fix ROC removal - avoids a firmware crash
* fix throughput regression on iwldvm devices
* fix panic in BT Coex
* fixes in rate control
* fixes in scan

b43:

* fix support for 5 GHz only BCM43228 model

rtlwifi:

* improve handling of IPv6 packets

brcmfmac:

* perform bound checking on vendor command buffer

----------------------------------------------------------------
Andrei Otcheretianski (1):
      iwlwifi: mvm: Fix ROC removal

Emmanuel Grumbach (2):
      iwlwifi: fix max_ht_ampdu_exponent for older devices
      iwlwifi: mvm: BT Coex - fix a NULL pointer exception

Eyal Shapira (2):
      iwlwifi: mvm: rs: fix BT Coex check to look at the correct ant
      iwlwifi: mvm: disable beamformer unless FW supports it

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-03-05' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: Improve handling of IPv6 packets

Luciano Coelho (2):
      iwlwifi: mvm: call ieee80211_scan_completed() even if scan abort =
fails
      iwlwifi: mvm: don't try to stop scans that are not running anymor=
e

Pontus Fuchs (1):
      brcmfmac: Perform bound checking on vendor command buffer

Rafa=C5=82 Mi=C5=82ecki (1):
      b43: fix support for 5 GHz only BCM43228 model

 drivers/net/wireless/b43/main.c                  |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/vendor.c |   15 +++++++--
 drivers/net/wireless/iwlwifi/iwl-1000.c          |    6 ++--
 drivers/net/wireless/iwlwifi/iwl-2000.c          |   13 +++++---
 drivers/net/wireless/iwlwifi/iwl-5000.c          |    6 ++--
 drivers/net/wireless/iwlwifi/iwl-6000.c          |   18 ++++++----
 drivers/net/wireless/iwlwifi/mvm/coex.c          |    3 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c   |    3 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c      |   38 ++++++++++++++=
++++++--
 drivers/net/wireless/iwlwifi/mvm/rs.c            |   21 ++++++++----
 drivers/net/wireless/iwlwifi/mvm/scan.c          |   13 ++++----
 drivers/net/wireless/iwlwifi/mvm/time-event.c    |    9 ++---
 drivers/net/wireless/rtlwifi/base.c              |    7 ++--
 13 files changed, 109 insertions(+), 44 deletions(-)

--=20
Kalle Valo
