From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] repairing rtcache killer
Date: Tue, 5 Aug 2003 19:08:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16175.58503.134543.310459@robur.slu.se>
References: <200308051340.RAA28267@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200308051340.RAA28267@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


kuznet@ms2.inr.ac.ru writes:
 > #   Two serious and interesting mistakes were made in the patch of 2003-06-16.
 > #   1. Variance of hash chain turned out to be unexpectedly high, so truncation
 > #      chain length at <=ip_rt_gc_elasticity results in strong growth of
 > #      cache misses. Set the threshould to 2*ip_rt_gc_elasticity.
 > #      And continue to think how to switch to mode when lots of cache
 > #      entries are used once or twice, so truncation should be done at 1.

 Hello!

 I'll guess the setting was very much affected by DoS attacs discussion which
 indicated very different flowlenths compared to our actual measurement for 
 Uppsala University which had 65 pkts per new DST entry. Proably due to the
 "new" applications and lots of students.

 For autotuning I think we can have help from a ratio of warm cache hits (in_hit)
 and misses (in_slow_tot) to set threshhold to trim hash chain lengths.
 
 Cheers.
						--ro
