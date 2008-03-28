From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 11:55:22 -0700
Message-ID: <47ED3F1A.1090101@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:42257 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751554AbYC1SzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 14:55:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The http://www.kerneloops.org website collects kernel oops and
warning reports from various mailing lists and bugzillas as well as
with a client users can install to auto-submit oopses.
Below is a top 10 list of the oopses collected in the last 7 days.
(Reports prior to 2.6.23 have been omitted in collecting the top 10)

This week, a total of 538 oopses and warnings have been reported,
compared to 169 reports in the previous week.


Rank 1: input_release_device
	This appears to be a regression in 2.6.25; the first reports show up in 2.6.25-rc2	
	Often a warning at kernel/mutex.c:134 (mutex_lock_nested), but some oopses too
	Reported 161 times (261 total reports)... this is 30% of the total reports this week!
	The reports are all in the fput() path via ev_release
	More info: http://www.kerneloops.org/searchweek.php?search=input_release_device

Rank 2: set_dentry_child_flags
	The standard inotify warning... only seen upto 2.6.24
	Assumed fixed in 2.6.25
	Reported 49 times (493 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=set_dentry_child_flags

Rank 3: __ieee80211_rx
	Warning at net/mac80211/rx.c:2184 __ieee80211_rx  (newer-than-mainline mac80211)
	Reported 29 times (73 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=__ieee80211_rx

Rank 4: radeon_vblank_crtc_set
	This is probably a Fedora-special experimental Radeon driver
	Reported 23 times (28 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=radeon_vblank_crtc_set

Rank 5: do_sys_open
	Oops because a driver returns "1" and not "-1" as error code
	Seen with the nouveau driver, not in mainline yet.
	Reported 21 times (39 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=do_sys_open

Rank 6: uvc_get_video_ctrl
	The uvc driver is not in mainline
	Reported 19 times (84 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=uvc_get_video_ctrl

Rank 7: __register_sysctl_paths
	Seen with proprietary drivers only
	Reported 16 times (186 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=__register_sysctl_paths

Rank 8: tcp_ack
	Warning at net/ipv4/tcp_input.c:2532 tcp_ack
	Reported 15 times (87 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=tcp_ack

Rank 9: sysctl_check_lookup
	This seems to be a bug in parport_device_proc_register()
	Reported 14 times (62 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=sysctl_check_lookup

Rank 10: mark_buffer_dirty
	This is an old friend, started in 2.6.24 and is still with us today.
	Often but not exclusively during unmounting of a filesystem
	Reported 12 times (39 total reports)
	More info: http://www.kerneloops.org/searchweek.php?search=mark_buffer_dirty


