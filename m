From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-10-25
Date: Wed, 25 Oct 2017 16:03:42 +0200
Message-ID: <20171025140343.21477-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.63.242]:52544 "EHLO
        sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751477AbdJYODt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:03:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here are a few more fixes for net, we started comprehensive testing
for the security issues and found that the problem wasn't addressed
in TKIP, so that's included, along with a handful other fixes.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 1b72bf5a0777d7cec6c2d857ac15599022b3c123:

  Merge tag 'mac80211-for-davem-2017-10-16' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2017-10-16 21:27:16 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-10-25

for you to fetch changes up to cfbb0d90a7abb289edc91833d0905931f8805f12:

  mac80211: don't compare TKIP TX MIC key in reinstall prevention (2017-10-25 11:04:45 +0200)

----------------------------------------------------------------
Here are:
 * follow-up fixes for the WoWLAN security issue, to fix a
   partial TKIP key material problem and to use crypto_memneq()
 * a change for better enforcement of FQ's memory limit
 * a disconnect/connect handling fix, and
 * a user rate mask validation fix

----------------------------------------------------------------
Jason A. Donenfeld (1):
      mac80211: use constant time comparison with keys

Johannes Berg (3):
      cfg80211: fix connect/disconnect edge cases
      mac80211: validate user rate mask before configuring driver
      mac80211: don't compare TKIP TX MIC key in reinstall prevention

Toke Høiland-Jørgensen (1):
      fq_impl: Properly enforce memory limit

 include/net/fq_impl.h |  9 ++++++---
 net/mac80211/cfg.c    | 12 ++++++------
 net/mac80211/key.c    | 37 +++++++++++++++++++++++++++++++++++--
 net/wireless/sme.c    | 50 +++++++++++++++++++++++++++++++++++++++++---------
 4 files changed, 88 insertions(+), 20 deletions(-)
