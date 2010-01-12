From: Florian Westphal <fw@strlen.de>
Subject: [iproute2] minor tc cleanup patches
Date: Tue, 12 Jan 2010 21:34:28 +0100
Message-ID: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:35418 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754617Ab0ALUea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:34:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen, hello Patrick,

here are 5 minor patches for iproute2/tc:
the first two are small man page adjustments.
The 3rd one makes tc print a more verbose error message instead of -EINVAL.

The 4th is a janitorial patch that removes some stale (c&p) code.

Last patch adds a man page for sched_drr.
Patrick, it would be nice if you could have a look at this one to see
if I got everything right (or if i forgot something important).

Thanks a lot!

Alternatively, you may pull from

git://git.breakpoint.cc/fw/iproute2.git cleanups

to obtain the following changes since commit
d63a9b2b1e4e3eab0d0577d0a0f412d50be1e0a7:
  Arnd Bergmann (1):
        iproute2/iplink: add macvlan options for bridge mode

Florian Westphal (5):
      tc: man: add limit parameter to tc-sfq man page
      tc: man: SO_PRIORITY is described in socket documentation, not tc one
      tc: red, gred, tbf: more helpful error messages
      tc: remove stale code
      tc: man: add man page for drr scheduler

 man/man8/tc-drr.8  |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tc-prio.8 |    2 +-
 man/man8/tc-sfq.8  |    3 ++
 man/man8/tc.8      |    1 +
 tc/f_fw.c          |    2 -
 tc/f_route.c       |    2 -
 tc/f_rsvp.c        |    2 -
 tc/f_tcindex.c     |    4 --
 tc/f_u32.c         |    2 -
 tc/q_atm.c         |    2 -
 tc/q_cbq.c         |    3 +-
 tc/q_drr.c         |    1 -
 tc/q_dsmark.c      |    3 --
 tc/q_fifo.c        |    2 -
 tc/q_gred.c        |    7 +---
 tc/q_htb.c         |    2 -
 tc/q_ingress.c     |    2 -
 tc/q_multiq.c      |    2 -
 tc/q_netem.c       |    2 -
 tc/q_prio.c        |    4 --
 tc/q_red.c         |   16 +---------
 tc/q_rr.c          |    3 --
 tc/q_sfq.c         |    2 -
 tc/q_tbf.c         |    8 ++--
 24 files changed, 101 insertions(+), 65 deletions(-)
 create mode 100644 man/man8/tc-drr.8
