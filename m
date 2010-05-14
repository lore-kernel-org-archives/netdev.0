From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: TSC unstable due to TSC halts in idle?
Date: Fri, 14 May 2010 22:13:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005142208290.6220@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Len Brown <len.brown@intel.com>,
	Shaohua Li <shaohua.li@intel.com>, hawk@comx.dk
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:44913 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861Ab0ENUOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 16:14:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Thomas,

I want to know, if its safe to enable the TSC clocksource, when the
kernel reports:
  "Marking TSC unstable due to TSC halts in idle"

The system selects HPET (in current_clocksource), but I can still see
TSC as an available clocksource (in
/sys/devices/system/clocksource/clocksource0/available_clocksource).

Is it safe to enable TSC manually (by changing current_clocksource)?
(my workload is 10Git/s routing, cannot survive with a slow clock)


Any trick to avoid this? (e.g. kernel config setting, or a /sys/ setting
which changes the minimum P-state?)


The system is a new HP370-G6 server, with two Xeon X5550 CPUs.  Its
(currently) running a Debian compiled kernel 2.6.26-2-amd64.

Kernel log:
  checking TSC synchronization [CPU#0 -> CPU#1]: passed.
  checking TSC synchronization [CPU#0 -> CPU#2]: passed.
  ...
  checking TSC synchronization [CPU#0 -> CPU#14]: passed.
  checking TSC synchronization [CPU#0 -> CPU#15]: passed.
  Marking TSC unstable due to TSC halts in idle


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
