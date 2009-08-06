From: Fabio Comolli <fabio.comolli@gmail.com>
Subject: WARNING: at net/mac80211/mlme.c:2292 ieee80211_sta_work+0x97/0xd2d
	[mac80211]()
Date: Thu, 6 Aug 2009 20:30:23 +0200
Message-ID: <b637ec0b0908061130w399eb1c6oc3a31640a76398c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754007AbZHFSaZ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just got this after a resume from suspend-to-ram. Wifi needed to be
disabled and reenabled (with hardware Fn+F2 key - this is an eeePC900)
to function  again.


[  919.858759] ------------[ cut here ]------------
[  919.858787] WARNING: at net/mac80211/mlme.c:2292
ieee80211_sta_work+0x97/0xd2d [mac80211]()
[  919.858791] Hardware name: 900
[  919.858793] Modules linked in: uvcvideo videodev v4l1_compat arc4
ecb ath5k mac80211 ath cfg80211
[  919.860022] Pid: 793, comm: phy0 Tainted: G   M       2.6.31-rc5 #11
[  919.860025] Call Trace:
[  919.860035]  [<c10209cf>] warn_slowpath_common+0x65/0x7c
[  919.860058]  [<f83d621e>] ? ieee80211_sta_work+0x97/0xd2d [mac80211]
[  919.860064]  [<c10209f3>] warn_slowpath_null+0xd/0x10
[  919.860086]  [<f83d621e>] ieee80211_sta_work+0x97/0xd2d [mac80211]
[  919.860092]  [<c101bb2b>] ? __wake_up+0x2f/0x56
[  919.860097]  [<c101bb39>] ? __wake_up+0x3d/0x56
[  919.860103]  [<c102eb04>] ? insert_work+0x96/0x9f
[  919.860108]  [<c102ed63>] ? __queue_work+0x32/0x49
[  919.860113]  [<c102eda1>] ? queue_work_on+0x27/0x2f
[  919.860119]  [<c102f52f>] ? queue_work+0x2d/0x45
[  919.860140]  [<f83d3324>] ?
ieee80211_ibss_notify_scan_completed+0x63/0x68 [mac80211]
[  919.860162]  [<f83d1059>] ? ieee80211_scan_completed+0x320/0x328 [mac80211]
[  919.860184]  [<f83d1160>] ? ieee80211_scan_work+0xb5/0x171 [mac80211]
[  919.860190]  [<c102f075>] worker_thread+0x15d/0x204
[  919.860211]  [<f83d6187>] ? ieee80211_sta_work+0x0/0xd2d [mac80211]
[  919.860218]  [<c1032217>] ? autoremove_wake_function+0x0/0x2f
[  919.860223]  [<c102ef18>] ? worker_thread+0x0/0x204
[  919.860229]  [<c1031fab>] kthread+0x63/0x68
[  919.860234]  [<c1031f48>] ? kthread+0x0/0x68
[  919.860240]  [<c1002f93>] kernel_thread_helper+0x7/0x10
[  919.860244] ---[ end trace 7a3a8d08c5a7bedf ]---
