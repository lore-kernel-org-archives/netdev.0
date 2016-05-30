From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH v2 00/10] nl80211: Fix checkpatch.pl issues
Date: Sun, 29 May 2016 19:49:57 -0700
Message-ID: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org, Julian.Calaby@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34012 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbcE3CuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 22:50:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set attempts to fix checkpatch.pl issues found in nl80211.c.
Each patch describes the specific warnings/checks/errors it addresses.
This patch-set ignores 'line over 80 chars' warnings, except for 2 cases.
Please check for issues with the 'fixes' for 'alignment should match
open parenthesis'. Some of them do not display correctly with git diff.
This patch-set removes 3 errors, 66 warnings and 46 checks.

Kirtika Ruchandani (10):
  nl80211: Fix checkpatch warnings
  nl80211: Fix checkpatch warnings about blank lines
  nl80211: Prefer ether_addr_copy
  nl80211: Fix checkpatch.pl warning about braces
  nl80211: Fix checkpatch.pl NULL comparison warning
  nl80211: Various checkpatch.pl spacing fixes
  nl80211: Avoid multiple assignments on same line
  nl80211: Fix spelling
  nl80211: Fix checkpatch.pl warning
  nl80211: Prefer kcalloc over kzalloc

Changes in v2:
- Break down patch into smaller independent patches as suggested by Julian 
  Calaby.This breaks down patch 3/3 in set v1 into patches 3-10 of v2.

 net/wireless/nl80211.c | 301 ++++++++++++++++++++++---------------------------
 1 file changed, 136 insertions(+), 165 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
