From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.4 SCTP updates
Date: Thu, 12 Aug 2004 17:24:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0408121716400.2931@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work

to get the following csets to bring 2.4 SCTP in sync with 2.6.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/12 14:15:26-07:00 sri@us.ibm.com
#   [SCTP] Mark chunks as ineligible for fast retransmit after they are
#   retransmitted. Also mark any chunks that could not be fit in the
#   PMTU sized packet as ineligible for fast retransmit.
#
# net/sctp/outqueue.c
#
# ChangeSet
#   2004/08/12 14:14:29-07:00 sri@us.ibm.com
#   [SCTP] Fix missing '+' in the computation of sack chunk size in
#   sctp_sm_pull_sack().
#
# net/sctp/sm_statefuns.c
#
# ChangeSet
#   2004/08/12 14:13:23-07:00 sri@us.ibm.com
#   [SCTP] Fix issues with handling stale cookie error over multihoming
#   associations.
#
# net/sctp/sm_statefuns.c
# net/sctp/sm_sideeffect.c
# include/net/sctp/command.h
#
# ChangeSet
#   2004/08/12 14:12:00-07:00 sri@us.ibm.com
#   [SCTP] Fix data not being delivered to user in SHUTDOWN_SENT state.
#
#   Also cleaned up sctp_sf_eat_data_6_2() and sctp_sf_eat_data_fast_4_4()
#   as they have a lot of common code.
#
# net/sctp/sm_statefuns.c
# net/sctp/associola.c
# include/net/sctp/sm.h
# include/net/sctp/constants.h
#
# ChangeSet
#   2004/08/12 14:08:40-07:00 sri@us.ibm.com
#   [SCTP] Set/Get default SCTP_PEER_ADDR_PARAMS for endpoint when associd
#   and peer address are 0.
#
# net/sctp/socket.c
#
# ChangeSet
#   2004/08/12 12:25:45-07:00 sri@us.ibm.com
#   [SCTP] SPARSE cleanup backported from 2.6
#
# net/sctp/ulpqueue.c
# net/sctp/ulpevent.c
# net/sctp/socket.c
# net/sctp/sm_statefuns.c
# net/sctp/protocol.c
# net/sctp/outqueue.c
# net/sctp/output.c
# net/sctp/inqueue.c
#

Thanks
Sridhar
