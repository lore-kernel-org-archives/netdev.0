From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6.1 SCTP updates.
Date: Mon, 19 Jan 2004 15:47:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401191531570.19907@localhost.localdomain>
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
to get the following udpdates to SCTP on top of linux 2.6.1

Some of these changesets have been in my repository for quite some time as
2.6.0 was closed for anything other than critical bug fixes before i went on
a vacation in early Dec 2003.
The csets include a few bug fixes and some ADDIP extension related patches.

# This patch includes the following deltas:
#                  ChangeSet    1.1503  -> 1.1507
#       net/sctp/associola.c    1.61.1.1 -> 1.64
#           net/sctp/input.c    1.36    -> 1.37
#       net/sctp/sm_statefuns.c 1.64    -> 1.67
#       net/sctp/sm_make_chunk.c        1.64    -> 1.66
#          net/sctp/output.c    1.32    -> 1.33
#       include/net/sctp/sctp.h 1.52.1.1 -> 1.54
#        net/sctp/outqueue.c    1.37.1.1 -> 1.39
#       include/net/sctp/constants.h    1.16    -> 1.17
#          net/sctp/sysctl.c    1.14    -> 1.15
#       include/net/sctp/sm.h   1.31    -> 1.33
#       include/linux/sysctl.h  1.52.1.2 -> 1.55
#        net/sctp/protocol.c    1.58    -> 1.60
#       include/linux/sctp.h    1.9     -> 1.10
#       net/sctp/sm_sideeffect.c        1.49    -> 1.51
#       net/sctp/sm_statetable.c        1.19    -> 1.21
#       include/net/sctp/structs.h      1.75    -> 1.78
#          net/sctp/socket.c    1.99.1.1 -> 1.104
#
# The following is the BitKeeper ChangeSet Log

ChangeSet@1.1507, 2004-01-19 11:12:44-08:00, sri@us.ibm.com
  [SCTP] provide valid tos and oif values for ip_route_output_key. (ja@ssi.bg)

ChangeSet@1.1506, 2004-01-16 10:58:25-08:00, sri@us.ibm.com
  [SCTP] Fix bugs in byte order conversion while processing address
  related SCTP socket options.

ChangeSet@1.1505, 2004-01-16 08:42:55-08:00, sri@us.ibm.com
  [SCTP] ADDIP: Handle T4 RTO timer expiry.

ChangeSet@1.1350.8.7, 2003-11-21 11:36:48-08:00, sri@us.ibm.com
  [SCTP] ADDIP: Support for processing incoming ASCONF_ACK chunks.

ChangeSet@1.1350.8.6, 2003-11-14 11:25:42-08:00, sri@us.ibm.com
  [SCTP] Fix overflow in the macros JIFFIES_TO_MSECS/MSECS_TO_JIFFIES
         when used with large values.

ChangeSet@1.1350.8.5, 2003-11-10 11:47:43-08:00, sri@us.ibm.com
  [SCTP] Fix the duplicate increment of checksum error counter and
         counting bad packet errors as checksum errors.

ChangeSet@1.1350.8.4, 2003-11-10 11:35:49-08:00, sri@us.ibm.com
  [SCTP] Fix to free associations in the accept queue of a one-to-one
         style listening socket that is closed.

ChangeSet@1.1350.8.3, 2003-10-28 17:19:26-08:00, sri@us.ibm.com
  [SCTP] ADDIP: Add sysctl parameter to enable/disable addip.

ChangeSet@1.1350.8.2, 2003-10-28 16:15:12-08:00, sri@us.ibm.com
  [SCTP] Remove the extra semicolon in sctp_cacc_skip_3_1().

ChangeSet@1.1350.8.1, 2003-10-28 16:12:52-08:00, sri@us.ibm.com
  [SCTP] ADDIP: Support for processing ASCONF chunks and respond with
         ASCONF_ACK chunks.

Thanks
Sridhar
