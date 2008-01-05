From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Sat, 05 Jan 2008 13:06:17 -0800
Message-ID: <477FF149.4070609@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:56837 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755922AbYAEVIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 16:08:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The http://www.kerneloops.org website collects kernel oops and
warning reports from various mailing lists and bugzillas as well as
with a client users can install to auto-submit oopses.
Below is a top 10 list of the oopses collected in the last 7 days.
(Reports prior to 2.6.23 have been omitted in collecting the top 10)

This week, a total of 49 oopses and warnings have been reported,
compared to 53 reports in the previous week.


Rank 1: __ieee80211_rx
	Warning at net/mac80211/rx.c:1672
	Reported 6 times (11 total reports)
	Same issue that was ranked 2nd last week
	Johannes has diagnosed this as a driver bug in the iwlwifi drivers
	More info: http://www.kerneloops.org/search.php?search=__ieee80211_rx

Rank 2: elv_next_request
	kernel page fault
	Reported 6 times (7 total reports)
	Seems to be related to fast modprobe/rmmod cycles
	More info: http://www.kerneloops.org/search.php?search=elv_next_request

Rank 3: d_splice_alias
	NULL pointer deref
	Reported 3 times
	Happens in the isofs code
	Only seen in 2.6.24-rc5-mm1
	More info: http://www.kerneloops.org/search.php?search=d_splice_alias

Rank 4: remove_proc_entry
	Was also ranked 4th last week
	Only in tainted oopses
	Reported 3 times (12 total reports)
	More info: http://www.kerneloops.org/search.php?search=remove_proc_entry

Rank 5: __d_path
	In the sys_getcwd system call
	Only reported for 2.6.23.x, by one user
	Reported 2 times
	More info: http://www.kerneloops.org/search.php?search=__d_path

Rank 6: device_release
	Was ranked 8th last week
	Same reports as last week, but now entered into bugzilla.kernel.org
	Reported 2 times (8 total reports)
	More info: http://www.kerneloops.org/search.php?search=device_release

Rank 7: pgd_alloc
	Has only been seen on machines tainted with the nvidia module
	Reported 2 times
	More info: http://www.kerneloops.org/search.php?search=pgd_alloc

Rank 8: evdev_disconnect
	kernel page fault
	Reported 2 times (10 total reports)
	Previously seen in older kernels including 2.6.21 but as far back as 2.6.16
	More info: http://www.kerneloops.org/search.php?search=evdev_disconnect

Rank 9: mutex_lock
	kernel null pointer due to rfcomm_tty_close sysfs interaction
	Reported 2 times (9 total reports)
	Ranked 9th last week as well
	More info: http://www.kerneloops.org/search.php?search=mutex_lock

Rank 10: lock_acquire
	WARNING: at kernel/lockdep.c:2658 check_flags()
	Reported 2 times (8 total reports)
	Seems related to __atomic_notifier_call_chain
	More info: http://www.kerneloops.org/search.php?search=lock_acquire


kerneloops.org news
* There is now a UI client so that if your kernel has an oops, you'll get asked for permission
   to submit this (rather than having to manually edit a config file as before)
* If you run the Gentoo distribution, please install the client using "emerge kerneloops"
* If you run the Fedora 8 (or rawhide) distribution, please install the rpm you can download
   from the http://www.kerneloops.org homepage
* If you run Debian unstable, please install the client via apt-get install kerneloops
