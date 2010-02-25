From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH 0/7] tcp: bugs and cleanup for 2.6.33
Date: Thu, 25 Feb 2010 15:30:03 -0500
Message-ID: <4B86DDCB.50608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'd have thought that there would be greater interest about patching
crashing bugs, signed versus unsigned (underflow) bugs, TCP DoS bugs,
TCP data corruption, and TCP performance problems....

Combination of patches reported in October, November, December, January,
and February, for 2.6.32 and now 2.6.33.

This code has had previous review and several months of limited testing.

Some portions were removed during the various TCPCT part 1 patch splits,
then were cut off by the sudden unexpected end of that merge window.
[03 Dec 2009]  I've restarted the sub-numbering (again).

Of particular interest are the TCPCT header extensions that already
appear in the next phase of testing with other platforms.  These patches
allow correct reception without data corruption.

The remainder of the original TCPCT part 2 will be merged with part 3.

[Updated to 2010 Feb 24 2.6.33 release.]
