From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 SCTP updates.
Date: Thu, 2 Oct 2003 16:46:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310021631550.2530-100000@localhost.localdomain>
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
to get the following udpates to SCTP on top of linux 2.6.0-test6

The changesets include fixes for a couple of arch specific issues with ppc64 
and parisc64, few ADDIP extension related patches and a bug fix.

# This patch includes the following deltas:
#	           ChangeSet	1.1375  -> 1.1377 
#	net/sctp/associola.c	1.59    -> 1.61   
#	net/sctp/sm_statefuns.c	1.63    -> 1.64   
#	net/sctp/endpointola.c	1.28    -> 1.29   
#	net/sctp/sm_make_chunk.c	1.61    -> 1.64   
#	include/net/sctp/sctp.h	1.50    -> 1.52   
#	   net/sctp/sysctl.c	1.13    -> 1.14   
#	include/net/sctp/sm.h	1.29    -> 1.31   
#	include/linux/sctp.h	1.8     -> 1.9    
#	net/sctp/sm_sideeffect.c	1.48    -> 1.49   
#	net/sctp/bind_addr.c	1.21    -> 1.22   
#	include/net/sctp/command.h	1.14    -> 1.15   
#	include/net/sctp/structs.h	1.73    -> 1.75   
#	   net/sctp/socket.c	1.96    -> 1.99   
#
# The following is the BitKeeper ChangeSet Log
#
#ChangeSet@1.1377, 2003-10-02 11:36:34-07:00, sri@us.ibm.com
#  [SCTP] Fix bugs in conversions between msecs and jiffies.
#
#ChangeSet@1.1376, 2003-09-29 12:04:57-07:00, sri@us.ibm.com
#  Merge us.ibm.com:/home/sridhar/BK/linux-2.6.0-test6
#  into us.ibm.com:/home/sridhar/BK/lksctp-2.6.0-test6
#
#ChangeSet@1.1217.15.5, 2003-09-29 10:23:40-07:00, sri@us.ibm.com
#  [SCTP] Convert tv_add from static inline to a macro to fix an obscure
#  assembler problem with parisc64.
#
#ChangeSet@1.1217.15.4, 2003-09-22 14:29:35-07:00, sri@us.ibm.com
#  [SCTP] ADDIP: Support for the creation of ASCONF_ACK chunk (Kevin).
#
#ChangeSet@1.1217.15.3, 2003-09-18 14:44:14-07:00, sri@us.ibm.com
#  [SCTP] ADDIP: Handle ERROR chunk in response to an ASCONF chunk.
#  
#  Disable sending any further ASCONF chunks and stop its T-4 timer if
#  the peer responds to an ASCONF with an ERROR chunk.
#
#ChangeSet@1.1217.15.2, 2003-09-18 14:39:59-07:00, sri@us.ibm.com
#  [SCTP] ADDIP: Support to send ASCONF chunk with ADD/DEL IP params.
#
#ChangeSet@1.1217.15.1, 2003-09-09 11:03:31-07:00, sri@us.ibm.com
#  [SCTP] PPC64 port: Don't overload the optval arg of ADDRS_NUM socket
#  options with different types for input and output. Instead use it only
#  as an input arg and return the no. of addresses in the return value.

Thanks
Sridhar
