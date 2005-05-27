From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] dsmark fixes & cleanups
Date: Fri, 27 May 2005 16:50:02 +0200
Message-ID: <20050527145002.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

The following patchset fixes various smallish bugs in dsmark
and does a general cleanup. The lower the patch number,
the less intrusive and more serious the bug is.

Patches tested using tc-testsuite (see below) and some
manual testing.

---
dsmark: dsmark root qdisc creation succeeded
dsmark: dsmark class 1 creation succeeded
dsmark: dsmark class 2 creation succeeded
dsmark: dsmark dump qdisc succeeded with output:
qdisc dsmark 10: indices 0x0040 default_index 0x0001 set_tc_index 
dsmark: dsmark dump class succeeded with output:
class dsmark 10:12 parent 10: mask 0xff value 0x02 
class dsmark 10:13 parent 10: mask 0xfc value 0x04 
dsmark: generic qdisc tree deletion succeeded
---
