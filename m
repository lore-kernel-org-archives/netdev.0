From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] PR-SCTP support, misc SCTP cleanups
Date: Mon, 19 Apr 2004 15:11:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404191457550.5385@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work &
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work
to get the following updates to 2.6 and 2.4 SCTP.

The updates include PR-SCTP(partial reliability extension) support and some
misc. bug fixes and cleanups.

Thanks
Sridhar

# ChangeSet
#   2004/04/19 11:26:22-07:00 sri@us.ibm.com
#   [SCTP] Propagate error from sctp_proc_init. (Olaf Kirch)
#
# net/sctp/protocol.c
#
# ChangeSet
#   2004/04/19 10:58:26-07:00 sri@us.ibm.com
#   [SCTP] Partial Reliability Extension support.
#
# net/sctp/ulpqueue.c
# net/sctp/tsnmap.c
# net/sctp/sysctl.c
# net/sctp/sm_statetable.c
# net/sctp/sm_statefuns.c
# net/sctp/sm_sideeffect.c
# net/sctp/sm_make_chunk.c
# net/sctp/protocol.c
# net/sctp/outqueue.c
# net/sctp/output.c
# net/sctp/debug.c
# net/sctp/chunk.c
# net/sctp/associola.c
# include/net/sctp/ulpqueue.h
# include/net/sctp/tsnmap.h
# include/net/sctp/structs.h
# include/net/sctp/sm.h
# include/net/sctp/sctp.h
# include/net/sctp/constants.h
# include/net/sctp/command.h
# include/linux/sysctl.h
# include/linux/sctp.h
#
# ChangeSet
#   2004/04/19 10:46:21-07:00 sri@us.ibm.com
#   [SCTP] Cleanup sctp_packet and sctp_outq infrastructure.
#
# net/sctp/transport.c
# net/sctp/sm_statefuns.c
# net/sctp/outqueue.c
# net/sctp/output.c
# net/sctp/associola.c
# include/net/sctp/structs.h
# include/net/sctp/constants.h
#
# ChangeSet
#   2004/04/19 10:36:56-07:00 sri@us.ibm.com
#   [SCTP] Avoid the use of constant SCTP_IP_OVERHEAD to determine the
#   max data size in a SCTP packet.
#
#   Calculate the overhead based on the socket's protocol family header
#   length.
#
# net/sctp/ulpevent.c
# net/sctp/socket.c
# net/sctp/outqueue.c
# net/sctp/output.c
# net/sctp/chunk.c
# include/net/sctp/structs.h
# include/net/sctp/sctp.h
# include/net/sctp/constants.h
#
