From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Top 9 kernel oopses/warnings for the week of December 29th, 2007
Date: Sat, 29 Dec 2007 12:34:39 +0100
Message-ID: <477630CF.5070609@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:51707 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752102AbXL2Lgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 06:36:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The http://www.kerneloops.org website collects kernel oops and
warning reports from various mailing lists and bugzillas as well as
with a client users can install to auto-submit oopses.
Below is a top 10 list of the oopses collected in the last 7 days.
(Reports prior to 2.6.23 have been omitted in collecting the top 10)

It has been a quiet week due to the holidays, only 55 oops traces
have been collected.

Rank 1: sysctl_head_finish
	sysctl table check failed
	Reported 7 times
	Only reported for the proprietary madwifi driver
	More info: http://www.kerneloops.org/search.php?search=sysctl_head_finish
	
Rank 2: __ieee80211_rx
	Warning at net/mac80211/rx.c:1672
	Reported 5 times
	Only seen in 2.6.24-rc6 so far
	Johannes has diagnosed this as a driver bug in the iwlwifi drivers
	More info: http://www.kerneloops.org/search.php?search=__ieee80211_rx
	
Rank 3: rb_erase
	Null pointer dereference
	Reported 4 times
	Only seen in 2.6.24-rc6 so far
	(Note: the reported removed the oops end marker manually; may be duplicate reports)
	More info: http://www.kerneloops.org/guilty.php?version=2.6.24-rc6&guilty=rb_erase&start=1574400&end=1574400

Rank 4: remove_proc_entry
	Warning at fs/proc/generic.c:736
	Reported 4 times for 2.6.24-rc4 and rc5 (Mandrake)
	Seems to be a module unload issue
	More info: http://www.kerneloops.org/search.php?search=remove_proc_entry
	
Rank 5: aes_encrypt
	Invalid kernel pointer oops
	Reported 2 times for 2.6.23.11
	More info: http://www.kerneloops.org/search.php?search=aes_encrypt
	
Rank 6: cascade
	BUG statement at kernel/timer.c:606
	Reported 2 times for 2.6.23 (Gentoo)
	More info: http://www.kerneloops.org/search.php?search=cascade
	
Rank 7: kref_put
	Kernel paging request
	Reported 2 times, only for 2.6.24-rc6-mm1
	Diagnosed as a bug in the md-subsystem, patch available
	More info: http://www.kerneloops.org/search.php?search=kref_put
	More info: http://article.gmane.org/gmane.linux.kernel/618056
	
Rank 8: device_release
	Warning at drivers/base/core.c:107
	Reported 2 times last week, 6 incidents total
	Seems to be a bug in the MTD physmap driver and the hgafb driver
	More info: http://article.gmane.org/gmane.linux.kernel/618076
	More info: http://article.gmane.org/gmane.linux.kernel/618076
	
Rank 9: mutex_lock
	Null pointer dereference
	Reported 2 times, of which one was a duplicate report
	Seems to be related to running PPP over a bluetooth link
	More info: http://www.kerneloops.org/guilty.php?version=2.6.24-rc6&guilty=mutex_lock&start=1574400&end=1574400
	

kerneloops.org news:
* As of 2.6.24-rc6, oopses have a unique identifier which makes it possible to filter out duplicate
   reports of (and replies to) the same oops. Unfortunately some reporters remove this line from
   their reports to lkml.
