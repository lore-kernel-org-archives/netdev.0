From: Andrew Morton <akpm@osdl.org>
Subject: gcc-3.5 patches
Date: Sun, 25 Jan 2004 03:06:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040125030624.54abfacf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Dave, let me unload a bunch of patches which fix compilation errors and
warnings with gcc-3.5.  Most or all of these are applicable to gcc-3.4 as
well.

The most common problem is using a typecasted expression as an lvalue. 
This is actually a fatal error in gcc-3.5.

The sctp fix is interesting - sctp.h is using attribute((packed)) on all
its structures and as far as I can tell, it never did anything.
