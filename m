From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6.2 SCTP updates
Date: Fri, 6 Feb 2004 17:24:32 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
to get the following udpates to SCTP on top of linux 2.6.2

These csets include fixes for a couple of issues that were reported by
SCTP users.
- Removed deprecated ADLER32 checksum support as it is unexpectedly
  getting selected in certain configurations (ex: allyesconfig) and we
  no longer need to support it.
- Updated the default max socket receive buffer to 64K from 32K and also
  added sysctl variables to change sctp socket send/receive buffers.

# This patch includes the following deltas:
#	           ChangeSet	1.1548  -> 1.1550
#	net/sctp/associola.c	1.64    -> 1.65
#	net/sctp/endpointola.c	1.29    -> 1.30
#	    net/sctp/Kconfig	1.7     -> 1.8
#	include/net/sctp/constants.h	1.17    -> 1.18
#	   net/sctp/sysctl.c	1.15    -> 1.16
#	include/linux/sysctl.h	1.57    -> 1.58
#	 net/sctp/protocol.c	1.59    -> 1.61
#	  net/sctp/adler32.c	1.8     ->         (deleted)
#	 net/sctp/ulpqueue.c	1.26    -> 1.27
#	include/net/sctp/structs.h	1.78    -> 1.79
#	   net/sctp/Makefile	1.9     -> 1.10
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
ChangeSet@1.1550, 2004-02-05 13:58:37-08:00, sri@us.ibm.com
  [SCTP] Removed the deprecated ADLER32 checksum support.

ChangeSet@1.1474.108.5, 2004-01-23 14:58:38-08:00, sri@us.ibm.com
  [SCTP] Add sysctl parameters to update socket send/receive buffers.

ChangeSet@1.1474.108.4, 2004-01-19 11:12:44-08:00, sri@us.ibm.com
  [SCTP] provide valid tos and oif values for ip_route_output_key. (ja@ssi.bg)

Thanks
Sridhar
