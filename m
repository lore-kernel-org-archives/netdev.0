From: Robin Holt <holt@sgi.com>
Subject: What is a reasonable upper limit to the rt_hash_table.
Date: Tue, 7 Dec 2004 11:25:10 -0600
Message-ID: <20041207172510.GC11423@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We have a system with a very large amount of memory.  We are noticing
pauses of approximately 5 seconds every 10 minutes.  We tracked it down
to rt_run_flush holding off other timer processing while it scans the
rt_hash_table.  The following is from the boot:

IP: routing cache hash table of 33554432 buckets, 524288Kbytes

This seems like an outrageously large value.  I realize the 2.6 kernel
has rhash_entries as a boot option.

Can I get some guidance on what a reasonable upper limit would be?
What is this guidance based upon?

What is the reason for not making that upper limit a default and let
rhash_entries override to make it larger if a site actually needed it?

Thank you in advance,
Robin Holt
