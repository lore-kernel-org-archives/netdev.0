From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 SCTP updates
Date: Fri, 13 Feb 2004 16:07:05 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402131443350.2190@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work
to get the following fixes to SCTP on top of linux 2.6.2.

# This patch includes the following deltas:
#                  ChangeSet    1.1551  -> 1.1554
#          net/sctp/ssnmap.c    1.2     -> 1.3
#          net/sctp/socket.c    1.105   -> 1.107
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/12      sri@us.ibm.com  1.1552
# [SCTP] Use __get_free_pages() to allocate ssnmap.
#
# This is needed to avoid kmalloc()'s 128K limit when an association is
# initialized with a large no. of streams(more than 65000 inbound +
# outbound streams).
# --------------------------------------------
# 04/02/12      sri@us.ibm.com  1.1553
# [SCTP] Fix SCTP_INITMSG set socket option so that a parameter with 0
#        value will not change its current value.
# --------------------------------------------
# 04/02/13      sri@us.ibm.com  1.1554
# [SCTP] Fix sctp_getladdrs()/sctp_getpaddrs() API so that the port
#        value in the returned addresses is in network byte order.
# --------------------------------------------

Thanks
Sridhar
