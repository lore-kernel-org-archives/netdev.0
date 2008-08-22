From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Thu, 21 Aug 2008 18:24:15 -0700 (PDT)
Message-ID: <165480.52635.qm@web82106.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82106.mail.mud.yahoo.com ([209.191.84.219]:26281 "HELO
	web82106.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752421AbYHVBYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 21:24:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> insert_resource/request_resource works well
> 
> can you verify if hpet work on old kernel?
> 
> cat /proc/timers*

$ ls /proc/t*
/proc/timer_list

/proc/tty:
driver    drivers  ldisc    ldiscs

$ grep -B 1 -A 5 hpet /proc/timer_list 
Tick Device: mode:     1
Clock Event Device: hpet
 max_delta_ns:   149983005959
 min_delta_ns:   3352
 mult:           61496114
 shift:          32
 mode:           1
 next_event:     9223372036854775807 nsecs
 set_next_event: hpet_legacy_next_event
 set_mode:       hpet_legacy_set_mode
 event_handler:  tick_handle_oneshot_broadcast
tick_broadcast_mask: 00000000
tick_broadcast_oneshot_mask: 00000000


If there's anything else I can do, just ask!
Dave W.
