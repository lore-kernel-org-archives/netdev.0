From: gozdal@gozdal.eu.org (Marcin Gozdalik)
Subject: Handling a few hundred thousand TCP flows
Date: Sun, 1 Feb 2004 22:58:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040201215836.GC16978@gozdal.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

I've been successfully using Linux 2.4 for handling many thousands TCP
flows (300k non-stop). I've been wondering which options I should use to
minimize CPU and memory consumption.
I've followed the thread from December about handling 90k TCP streams
and suggestions contained there. I thought however of some more radical
solutions: disabling rt_cache altogether. The routing table contains
whole 2 entries (for eth0 subnet and default gateway) so I'd assume that
walking linearily such short list would be a win cache-wise compared to
huge rt_cache? Or is it a completely stupid idea not worth implementing?
Additionally, I've disabled ECN and SACKs. Does it make any sense? Or
are performance/memory gains negligible?

Cheers,
Marcin
