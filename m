From: "Mendelson, Tsippy" <tsippy.mendelson@intel.com>
Subject: del_timer_sync() synchronization rules
Date: Wed, 14 Jan 2004 12:38:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <2C83850C013A2540861D03054B478C0602012334@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="windows-1255"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>,
        "iJR ICGJ SW Dev Linux ANS" <ijr.icgj.sw.dev.linux.ans@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


In the header of the del_timer_sync() function in 2.4.x kernels it says:

* Caller must disable by some means restarting the timer
* for new.

In kernel 2.6.1 the header says:

* Synchronization rules: callers must prevent restarting of the timer,
* otherwise this function is meaningless.

Does anyone know what this is about?

Does this imply that a timer that restarts itself must use some other means
to prevent it from restarting once del_timer_sync was called? (like some kind of terminate flag)

If so - isn't this just what dell_timer_sync is supposed to handle properly?
If not - then what kind of scenario is this referring to?

Tsippy  
