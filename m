From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 0/5 2.5] e100: driver update
Date: Fri, 15 Oct 2004 06:53:10 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150547480.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1. Fix e100_watchdog to not accidentally re-enable interrupts when setting 
the software interrupt bit.  Bug fixed was data corruption noticed with i
memory poisoning kernel, when under heavy (65000+) packets per second load on PPC64.
2. Downing interface breakes connectivity of BMC removed small portion of 
TCO workaround in e100_hw_reset routine
3. Fix set ringparam for ethtool returning error code on bad input
4. Driver version number update
5. More DPRINTK messages to log driver state.
