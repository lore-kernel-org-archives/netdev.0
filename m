From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Top 10 kernel oopses/warnings for the week of December 21st 2007
Date: Fri, 21 Dec 2007 12:51:11 +0100
Message-ID: <476BA8AF.4060201@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	"Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:53878 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759607AbXLULzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 06:55:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The http://www.kerneloops.org website collects kernel oops and
warning reports from various mailing lists and bugzillas as well as
with a client users can install to auto-submit oopses.
Below is a top 10 list of the oopses collected in the last 7 days.
(Reports prior to 2.6.23 have been omitted in collecting the top 10)

This week a total of 100 oopses have been collected, up from 59 last week.
(This does not mean that the kernel quality has gone down; rather it means
that there's more effective data collection)

Rank 1: ieee80211_tx
	Warning at net/mac80211/tx.c:1093 in ieee80211_tx()
	Reported 30 times
	Only reported for 2.6.24-rc5 so far
	Probably specific to the rt2x00pci driver
	More info: http://www.kerneloops.org/search.php?search=ieee80211_tx
	
Rank 2: uart_flush_buffer
	Warning at drivers/serial/serial_core.c:544 in uart_flush_buffer()
	Reported 16 times
	No specific version information reported; bug present in 2.6.24-rc5
	Caused by a bug in the Bluetooth line discipline/tty code
	More info: http://lkml.org/lkml/2007/12/20/314 (analysis)
	More info: http://lkml.org/lkml/2007/12/20/414 (patch)
	More info: http://www.kerneloops.org/search.php?search=uart_flush_buffer
	
Rank 3: anon_vma_link
	Kernel page fault
	Reported 4 times
	Reported for 2.6.23.9 and 2.6.23.11
	So far only reported for reiserfs4 patched kernels
	More info: http://www.kerneloops.org/search.php?search=anon_vma_link
	
Rank 4: acpi_idle_enter_bm
	Soft lockup / crash
	Reported 3 times
	Reported for 2.6.23.8 (FC8) and 2.6.24-rc4
	Idle path: could be a hardware issue
	More info: http://www.kerneloops.org/search.php?search=acpi_idle_enter_bm
	
Rank 5:	iput
	Null pointer
	Reported 3 times
	No specific version information
	ISOFS specific; could be caused by an invalid iso formatted disk (security issue)
	More info: http://www.kerneloops.org/oops.php?number=2493
	More info: http://www.kerneloops.org/guilty.php?version=<unknown>&guilty=iput&start=0&end=0

Rank 6: acpi_idle_enter_simple
	Soft lockup
	Reported 2 times
	Reported only for 2.6.23.8 (FC8)
	Idle path: could be a hardware issue
	Possibly related to this weeks Rank 4 issue
	More info: http://www.kerneloops.org/search.php?search=acpi_idle_enter_simple
	
Rank 7: uart_write
	Warning at drivers/serial/serial_core.c:490 in uart_write()
	Reported 2 times
	No specific version information
	Appears to be a similar bug to the one in this weeks Rank 2
	More info: http://www.kerneloops.org/search.php?search=uart_write
	
Rank 8: __change_page_attr
	BUG at arch/x86/mm/pageattr_64.c:176
	Reported 2 times
	Reported this week for 2.6.24-rc5; history goes back to 2.6.15
	More info: http://www.kerneloops.org/guilty.php?version=2.6.24-rc5&guilty=__change_page_attr&start=1574144&end=1574144

Rank 9: r_show
	Kernel NULL pointer
	Reported 2 times
	Reported only for the -mm tree: 2.6.24-rc5-mm1
	More info: http://www.kerneloops.org/search.php?search=r_show
	
Rank 10: set_dentry_child_flags
	Warning at fs/inotify.c:172 in set_dentry_child_flags()
	Reported 2 times
	No specific version information
	Inotify related
	More info: http://www.kerneloops.org/search.php?search=set_dentry_child_flags
	
	
	
Website news / improvements:
    * Various user feedback is now incorportated; keep this coming!
		* Improved banner
		* BUG/WARN_ON's now have a direct link to the specific line of code in git-web
    * The oops submit client is now included in the Debian (unstable) and Gentoo distributions

