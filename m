From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 and 2.4 SCTP updates
Date: Thu, 30 Dec 2004 16:53:56 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0412301645380.6939@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work &
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work

to get the following SCTP updates to 2.6 and 2.4.

The 2.4 csets include a patch that gets rid of sk_xxx macros that were
causing backporting issues for other networking components.

Thanks
Sridhar

# ChangeSet
#   2004/12/30 15:50:53-08:00 sri@us.ibm.com
#   [SCTP] Fix sctp_getladdrs() to return valid local addresses on an endpoint
#   that is bound to INADDR_ANY or inaddr6_any.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/socket.c
#
# ChangeSet
#   2004/12/29 11:35:11-08:00 sri@us.ibm.com
#   [SCTP] Fix misc. issues in SCTP_PEER_ADDR_PARAMS set socket option.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/transport.c
# net/sctp/socket.c
# net/sctp/sm_sideeffect.c
# net/sctp/associola.c
# include/net/sctp/structs.h
#
# ChangeSet
#   2004/12/28 17:04:30-08:00 sri@us.ibm.com
#   [SCTP] Fix bug in setting ephemeral port in the bind address.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/socket.c
#
# ChangeSet
#   2004/12/28 16:22:41-08:00 sri@us.ibm.com
#   [SCTP] Clean up the T3_rtx timer when deleting a transport.
#
#   Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/transport.c
#
# ChangeSet
#   2004/12/28 16:03:30-08:00 sri@us.ibm.com
#   [SCTP] Implementation of SCTP Implementer's Guide Section 2.35.
#   This code checks that the verification tag, source port and
#   destination port in the SCTP header matches the information
#   contained in the state cookie.
#
#   Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_make_chunk.c
# net/sctp/associola.c
# include/net/sctp/structs.h
# include/net/sctp/constants.h
#
# ChangeSet
#   2004/12/28 15:47:51-08:00 sri@us.ibm.com
#   [SCTP] Validate and respond to invalid chunk/parameter lengths.
#
#   Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_statefuns.c
# net/sctp/sm_make_chunk.c
# net/sctp/inqueue.c
# net/sctp/input.c
# net/sctp/endpointola.c
# net/sctp/associola.c
# include/net/sctp/sm.h
# include/net/sctp/sctp.h
# include/linux/sctp.h
#
# ChangeSet
#   2004/12/27 14:13:06-08:00 sri@us.ibm.com
#   [SCTP] Treat ICMP protocol unreachable errors from non-SCTP capable hosts as ABORTs.
#
#   Signed-off-by: Jerome Forrissier <jerome.forrissier@hp.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_statetable.c
# net/sctp/sm_statefuns.c
# net/sctp/ipv6.c
# net/sctp/input.c
# net/sctp/debug.c
# include/net/sctp/sm.h
# include/net/sctp/sctp.h
# include/net/sctp/constants.h
#
# ChangeSet
#   2004/12/27 10:51:01-08:00 sri@us.ibm.com
#   [SCTP] Code cleanup: remove unused code and make needlessly global code static
#
#   Signed-off-by: Adrian Bunk <bunk@stutsa.de>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/ulpqueue.c
# net/sctp/ulpevent.c
# net/sctp/tsnmap.c
# net/sctp/transport.c
# net/sctp/ssnmap.c
# net/sctp/socket.c
# net/sctp/sm_statetable.c
# net/sctp/sm_statefuns.c
# net/sctp/sm_sideeffect.c
# net/sctp/sm_make_chunk.c
# net/sctp/protocol.c
# net/sctp/proc.c
# net/sctp/outqueue.c
# net/sctp/objcnt.c
# net/sctp/ipv6.c
# net/sctp/inqueue.c
# net/sctp/input.c
# net/sctp/endpointola.c
# net/sctp/debug.c
# net/sctp/command.c
# net/sctp/chunk.c
# net/sctp/bind_addr.c
# net/sctp/associola.c
# include/net/sctp/ulpqueue.h
# include/net/sctp/ulpevent.h
# include/net/sctp/tsnmap.h
# include/net/sctp/structs.h
# include/net/sctp/sm.h
# include/net/sctp/sctp.h
# include/net/sctp/constants.h
# include/net/sctp/command.h
#
# ChangeSet
#   2004/12/24 22:33:13-08:00 sri@us.ibm.com
#   [SCTP] Fix potential null pointer dereference in sctp_err_lookup().
#
#   Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/input.c
#
