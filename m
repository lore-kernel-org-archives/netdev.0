From: Theodore Ts'o <tytso@mit.edu>
Subject: [REGRESSION v3.14-rc2] NULL dereference in icmp6_send()
Date: Mon, 17 Feb 2014 13:46:13 -0500
Message-ID: <nsxzjlp4lxm.fsf@closure.thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I was sitting in the Admiral's Club of Boston Logan airport, having
connected to the free airport wifi, although I had not yet logged into
the captive portal, when I received the following BUG.   I've also seen
this once before when connected to my home network (running the CeroWRT
stable snapshot, versoin 3.7.5-2), although I wasn't able to get a
screen shot that time:

https://plus.google.com/photos/+TheodoreTso/albums/5981437894092747105/5981437896646076466

The transcribed stack dump is:

icmp6_send
ip6_expire_frag_queue
ip6_frag_expire
call_timer_fn
run_timer_softirq
irq_exit
...

I was running v3.13 and v3.13-rcX previously without seeing this, so I
suspect this is a regression.

Cheers,

                                                - Ted
