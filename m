From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] SCTP updates.
Date: Thu, 4 Sep 2003 15:55:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309041440330.21476-100000@localhost.localdomain>
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
to get the following updates to SCTP on top of linux 2.6.0-test4

The changesets include API updates to be compatible with the latest SCTP 
sockets API Extension draft 
   http://www.ietf.org/internet-drafts/draft-ietf-tsvwg-sctpsocket-07.txt
and a few bug fixes.

# This patch includes the following deltas:
#	           ChangeSet	1.1316  -> 1.1324 
#	include/net/sctp/user.h	1.14    -> 1.15   
#	net/sctp/associola.c	1.58    -> 1.59   
#	    net/sctp/input.c	1.35    -> 1.36   
#	net/sctp/sm_statefuns.c	1.62    -> 1.63   
#	net/sctp/sm_make_chunk.c	1.58    -> 1.61   
#	include/net/sctp/sctp.h	1.47    -> 1.50   
#	   net/sctp/sysctl.c	1.12    -> 1.13   
#	include/net/sctp/sm.h	1.27    -> 1.29   
#	 net/sctp/protocol.c	1.57    -> 1.58   
#	     net/sctp/ipv6.c	1.48    -> 1.49   
#	include/linux/sctp.h	1.7     -> 1.8    
#	net/sctp/bind_addr.c	1.19    -> 1.21   
#	include/net/sctp/structs.h	1.71    -> 1.73   
#	net/sctp/primitive.c	1.10    -> 1.11   
#	   net/sctp/socket.c	1.89    -> 1.95   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/25	sri@us.ibm.com	1.1123.20.2
# [SCTP] draft07 API changes: sctp_getpaddrs(), sctp_getladdrs() now
# return a packed array of sockaddr_in/sockaddr_in6 structures instead
# of an array of sockaddr_storage structures.
# --------------------------------------------
# 03/08/25	sri@us.ibm.com	1.1317
# Merge us.ibm.com:/home/sridhar/BK/linux-2.6.0-test4
# into us.ibm.com:/home/sridhar/BK/lksctp-2.6.0-test4
# --------------------------------------------
# 03/08/27	sri@us.ibm.com	1.1318
# [SCTP] SCTP_SET_PEER_PRIMARY socket option support. (Kevin Gao)
# --------------------------------------------
# 03/08/29	sri@us.ibm.com	1.1319
# [SCTP] draft07 API changes: sctp_bindx() now takes a packed array of
# sockaddr_in/sockaddr_in6 structures instead of an array of
# sockaddr_storage structures.
# --------------------------------------------
# 03/09/02	sri@us.ibm.com	1.1320
# [SCTP] Convert sctp_param2sockaddr() and sockaddr2sctp_addr() to
# address family specific routines af->from_addr_parm() and
# af->to_addr_param() respectively. 
# --------------------------------------------
# 03/09/03	sri@us.ibm.com	1.1321
# [SCTP] Fix a couple of issues with the call to sctp_ssnmap_new() in
# sctp_process_init().
# 
# The argument passed as inbound streams to sctp_ssnmap_new() is
# incorrect. Also allocating a ssnmap everytime a INIT is received is
# vulnerable to DoS attacks. So delay the creation of an ssnmap if we
# are processing a temporary association. 
# --------------------------------------------
# 03/09/03	sri@us.ibm.com	1.1322
# [SCTP] draft 07 API changes: Disable listening when backlog is 0.
# --------------------------------------------
# 03/09/03	sri@us.ibm.com	1.1323
# [SCTP] draft 07 API changes: By default, all the event notifications
# are turned off even for one-to-many style sockets.
# --------------------------------------------
# 03/09/04	sri@us.ibm.com	1.1324
# [SCTP] Move a local variable declaration ahead of the function code.
# 
# Apparently the new gcc 3.2.2 allows local variable declarations within
# the code of a function if it is not used earlier. But older gcc's do
# not allow this. 
# --------------------------------------------

Thanks
Sridhar
