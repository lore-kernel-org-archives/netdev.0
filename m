From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Flow cache uses unsigned long for cpu mask.
Date: Sun, 02 Nov 2003 16:34:35 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031102062345.8755A2C003@lists.samba.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org, kuznet@ms2.inr.ac.ru, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

net/core/flow.c uses "unsigned long flow_cache_cpu_map": AFAICT this
should be a cpumask_t.

Just doing an unrelated audit...
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
