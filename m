From: Andrew Morton <akpm@osdl.org>
Subject: fib_hash.c:fn_hash()
Date: Thu, 24 Jun 2004 01:09:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624010938.55f90500.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Current gcc CVS emits a memmove() when compiling this function, and the
kernel link fails.

The gcc guys are being rude about it:

http://gcc.gnu.org/bugzilla/show_bug.cgi?id=16172
