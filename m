From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 0/10] ixgb: driver update
Date: Fri, 29 Oct 2004 05:07:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290440220.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

1.  Fix NAPI driver crash on ifdown during traffic
2.  Fix error in setting Frame Size register while changing mtu 
3.  Prevent infinite loop trying to re-establish link while actively 
communicating
4.  Remove sub-device ids for non-existant hardware
5.  Limit Rx Address Filter Array entries to 3
6.  Shrink size of ixgb_buffer (use uint16_t for length/next_to_watch)
7.  Replace kmalloc with vmalloc to allocate driver local data structures
8.  Ethtool_ops support
9.  Version number update
10. White space corrections
