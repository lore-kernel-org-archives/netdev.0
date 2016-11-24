From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/4] Fix -Wunused-but-set-variable in net/mac80211/
Date: Wed, 23 Nov 2016 20:45:23 -0800
Message-ID: <cover.1479962513.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Marek Kwaczynski <marek.kwaczynski-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        David Spinadel <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Alexander Bondar <alexander.bondar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patchset is part of the effort led by Arnd Bergmann to clean up
warnings in the kernel. This and following patchsets will focus on
"-Wunused-but-set-variable" as it among the noisier ones. These were
found compiling with W=1.

Kirtika Ruchandani (4):
  mac80211: Removed unused 'i' variable
  mac80211: Remove unused 'len' variable
  mac80211: Removed unused 'struct ieee80211_supported_band*' variable
  mac80211: Remove unused 'beaconint_us' variable

 net/mac80211/chan.c | 4 +---
 net/mac80211/mlme.c | 4 ----
 net/mac80211/scan.c | 8 +++-----
 net/mac80211/vht.c  | 4 ----
 4 files changed, 4 insertions(+), 16 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
