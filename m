From: Max Krasnyansky <maxk@qualcomm.com>
Subject: [BK] TUN driver updates and fixes for 2.6
Date: Tue, 21 Oct 2003 09:39:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20031021090148.05451c60@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, 

Please pull from
        bk://linux-bt.bkbits.net/tun-2.5

This will update the following files:

 drivers/net/tun.c      |   99 ++++++++++++++++++++++++-------------------------
 include/linux/if_tun.h |    8 +--
 2 files changed, 53 insertions(+), 54 deletions(-)

through these ChangeSets:

<maxk@qualcomm.com> (03/10/21 1.1348)
   [TUN] TUN/TAP driver updates and fixes.
   
   - Cleanup debug macros. 
   Replaced DBG() with TUN_DBG() to avoid conflicts.
   
   - Autodetect IP version and set protocol accordingly.
   
   - Use set_current_state() instead of accessing current->state directly.
    
   - Optimized net device registration.
   Do not call dev_get_by_name() unless name has '%' character in it. 
   This avoids extra scan of the net device list.
   
   - Return error code returned by misc_register() (instead of EIO) in
   case of failure.

Thanks

Max

http://bluez.sf.net
http://vacum.sf.net
http://vtun.sf.net
