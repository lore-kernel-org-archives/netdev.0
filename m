From: Shmuel Hen <shmulik.hen@intel.com>
Subject: [PATCH SET] bonding cleanup - take 4
Date: Tue, 23 Dec 2003 14:27:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312231427.22939.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A465D8@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="tscii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A465D8@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Here is another go with the bonding cleanup. This set is similar to
the previous set I sent with an additional patch for last minute fixes 
after getting a few rejects from Jeff Garzik. There is also a second 
set for bonding in 2.6.

The sets apply on 2.4.23 and on 2.6.0+latest changes from Jeff 
Garzik's net-drivers-2.5-exp BK tree.

They can be downloaded from:
http://prdownloads.sourceforge.net/bonding/bonding_cleanup_4-2.4.23.tar.bz2
http://prdownloads.sourceforge.net/bonding/bonding_cleanup_4-2.6.0.tar.bz2

This will update the following files:
        Documentation/networking/bonding.txt
        Documentation/networking/ifenslave.c
        drivers/net/bonding/bond_3ad.c
        drivers/net/bonding/bond_alb.c
        drivers/net/bonding/bond_alb.h
        drivers/net/bonding/bonding.h
        drivers/net/bonding/bond_main.c
        include/linux/if_bonding.h

Description:
patch 1 - ifenslave lite - No more IP settings to slaves, unified
          printing format, code re-org and broken to more
          functions.
patch 2 - convert all debug prints to use the dprintk macro and
          consolidate format of all prints (e.g. "bonding: Error:
          ...").
patch 3 - death of typedef. eliminate bonding_t/slave_t types and
          consolidate casting.
patch 4 - remove dead code and redundant checks.
patch 5 - consolidate timers initialization, error checking and
          re-queuing.
patch 6 - convert too long if-else to a switch-case. Fix all
          locations that handles bond->primary.
patch 7 - eliminate the multicast_mode module param. settings are
          now done only according to mode.
patch 8 - slave list iteration - bond is no longer part of the
          list, added cyclic list iteration macros.
patch 9 - consolidate function declarations:
          o all functions begin with bond_
          o return value, function name and all params are on the
            same line.
          o change some function names to be more descriptive.
patch 10 - consolidate names of function params and variables (e.g.
           bond_dev instead of dev/master/master_dev).
patch 11 - change names/types for some of the members in struct
           bonding. change position of members.
patch 12 - consolidate return values of functions.
patch 13 - put curly braces around all if, else, for, while, switch
           statements. change conditions to short format.
           e.g. (ptr == NULL) ==(!ptr)
patch 14 - consolidate error handling in all xmit functions.
patch 15 - chomp all trailing white space.
patch 16 - remove duplicate empty lines. add empty lines where
           needed to improve readability.
patch 17 - fix indentations.
patch 18 - code re-organization in bond_main.c according to context
           (e.g. module initialization, bond initialization, device
           entry points, monitoring, etc).
patch 19 - According to Jeff's recommendations: 
           o Put constant expressions in a constant. 
           o Put parentheses in calculations to improve readability. 
           o Remove redundant cast from void pointer. 

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
