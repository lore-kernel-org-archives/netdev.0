From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 0/16 2.5] ixgb driver update
Date: Fri, 15 Oct 2004 06:56:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150616290.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1.  Fix VLAN filter setup errors (while running on PPC)
2.  Fix memory leak in NAPI mode. Avoid unnecessary work in NAPI Rx cleanup, 
    if we are done
3.  Fix endianess issue for Tx cleanup
4.  Fix NAPI driver crash on ifdown during traffic
5.  Condition that determines when to quit polling mode includes
    work done in Tx path
6.  Fix error in setting Frame Size register while changing mtu 
7.  Prevent infinite loop trying to re-establish link while actively
    communicating
8.  Remove sub-device ids for non-existant hardware.
9.  Limit Rx Address Filter Array entries to 3
10. Shrink size of ixgb_buffer (use uint16_t for length/next_to_watch)
11. Explicitly include workqueue.h
12. Replace kmalloc with vmalloc to allocate driver local data structures
13. Ethtool_ops support
14. Version number update
15. White space corrections -- 1/2
16. White space corrections -- 2/2
