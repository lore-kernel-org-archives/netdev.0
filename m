From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: patches for PROC_FS=n (2.6.0-test7)
Date: Fri, 10 Oct 2003 14:16:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010141646.779f10bb.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lkml <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


drivers/char/toshiba.c and
net/atm/clip.c don't build if PROC_FS=n.

Patches for them are available at:

http://developer.osdl.org/rddunlap/patches/toshiba_inline_260t7.patch
http://developer.osdl.org/rddunlap/patches/atmprocfs_260t7.patch

There are several other drivers/protocols that don't build
with PROC_FS=n, like arlan, siimage, ipx, llc, and bluetooth.

--
~Randy
