From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] Minor updates to SCTP
Date: Wed, 6 Aug 2003 16:32:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308051515120.6261-100000@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5 

to get the following updates to SCTP on top of linux 2.6.0-test2.

# This patch includes the following deltas:
#	           ChangeSet	1.1595  -> 1.1597 
#	net/sctp/associola.c	1.57    -> 1.58   
#	    net/sctp/input.c	1.34    -> 1.35   
#	net/sctp/sm_statefuns.c	1.61    -> 1.62   
#	net/sctp/endpointola.c	1.27    -> 1.28   
#	net/sctp/sm_make_chunk.c	1.57    -> 1.58   
#	include/net/sctp/constants.h	1.15    -> 1.16   
#	    net/sctp/debug.c	1.8     -> 1.9    
#	     net/sctp/proc.c	1.6     -> 1.7    
#	include/net/sctp/sm.h	1.26    -> 1.27   
#	 net/sctp/protocol.c	1.56    -> 1.57   
#	include/linux/sctp.h	1.6     -> 1.7    
#	net/sctp/sm_sideeffect.c	1.47    -> 1.48   
#	net/sctp/sm_statetable.c	1.18    -> 1.19   
#	include/net/sctp/command.h	1.13    -> 1.14   
#	include/net/sctp/structs.h	1.69    -> 1.71   
#	   net/sctp/socket.c	1.88    -> 1.89   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/04	sri@us.ibm.com	1.1596
# [SCTP] ADDIP basic infrastructure support. (Ardelle.Fan)
# --------------------------------------------
# 03/08/04	sri@us.ibm.com	1.1597
# [SCTP] Fix to avoid large kmalloc failures on 64-bit platforms.
# 
# When spinlock debugging is enabled, the size of assoc hash table and
# port hash table for a fixed value of 4096 entries exceeds the size
# of the largest possible kmalloc() on 64-bit platforms. This problem is
# avoided by using page allocations similar to the methodology followed
# for tcp hash table allocations.
# --------------------------------------------

Thanks
Sridhar
