From: ganesh.venkatesan@intel.com
Subject: [PATCH 0/12 2.4] e1000 driver update
Date: Thu, 29 Jul 2004 08:25:45 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290036140.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff:

Patches against 2.4 tot --
1 -- ethtool support cleanup, register dump chacks controller type before 
dumping registers, interrupt diagnostic test addresses shared IRQ case
2 -- Enable TSO needs another patch to be submitted separately
3 -- replace kmalloc with vmalloc for data structures that are not shared 
with the hardware
4 -- TSO context descriptor setup fixes (in preparation for IPv6 TSO)
5 -- Fix to prevent infinite loop trying to re-establish link while 
actively attempting to communicate
6 -- Fix the condition that determines when to quit pollong mode to 
include work done in the Tx path
7 -- empty (not a patch)
8 -- Shutdown PHY while bringing the interface down (if WoL is not 
enabled)
9 -- add likely/unlikely to assist branch prediction, other cleanup
10 -- more DPRINTK messages
11 -- suspend/resume fix from alex@zodiac.dasalias.org
12 -- white space corrections

thanks,
ganesh.
