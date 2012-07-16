From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PULL net-next] tipc: kill off struct print_buf/log
Date: Mon, 16 Jul 2012 15:38:02 -0400
Message-ID: <20120716193801.GA1838@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<erik.hugne@ericsson.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57275 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293Ab2GPTiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 15:38:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is the same eight commits as sent for review last week[1],
with just the incorporation of the pr_fmt change as suggested
by JoeP.  There was no additional change requests, so unless you
can see something else you'd like me to change, please pull.

Thanks,
Paul.

[1] http://www.spinics.net/lists/netdev/msg204448.html

---

The following changes since commit 48ee3569f31d91084dc694fef5517eb782428083:

  ipv6: Move ipv6 twsk accessors outside of CONFIG_IPV6 ifdefs. (2012-07-11 02:39:24 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to 869dd4662f90514cb92b44a389e85c737b464e25:

  tipc: remove print_buf and deprecated log buffer code (2012-07-13 19:34:43 -0400)

----------------------------------------------------------------
Erik Hugne (5):
      tipc: use standard printk shortcut macros (pr_err etc.)
      tipc: remove TIPC packet debugging functions and macros
      tipc: simplify print buffer handling in tipc_printf
      tipc: phase out most of the struct print_buf usage
      tipc: remove print_buf and deprecated log buffer code

Paul Gortmaker (3):
      tipc: factor stats struct out of the larger link struct
      tipc: limit error messages relating to memory leak to one line
      tipc: simplify link_print by divorcing it from using tipc_printf

 include/linux/tipc_config.h |    4 +-
 net/tipc/Kconfig            |   25 ----
 net/tipc/bcast.c            |   65 +++++----
 net/tipc/bearer.c           |   62 +++++----
 net/tipc/bearer.h           |    2 +-
 net/tipc/config.c           |   41 +++---
 net/tipc/core.c             |   18 +--
 net/tipc/core.h             |   65 +--------
 net/tipc/discover.c         |   10 +-
 net/tipc/handler.c          |    4 +-
 net/tipc/link.c             |  304 +++++++++++++++++++------------------------
 net/tipc/link.h             |   63 ++++-----
 net/tipc/log.c              |  302 ++----------------------------------------
 net/tipc/log.h              |   66 ----------
 net/tipc/msg.c              |  242 ----------------------------------
 net/tipc/name_distr.c       |   25 ++--
 net/tipc/name_table.c       |  132 ++++++++++---------
 net/tipc/net.c              |    8 +-
 net/tipc/netlink.c          |    2 +-
 net/tipc/node.c             |   22 ++--
 net/tipc/node_subscr.c      |    3 +-
 net/tipc/port.c             |   66 +++++-----
 net/tipc/ref.c              |   10 +-
 net/tipc/socket.c           |   10 +-
 net/tipc/subscr.c           |   14 +-
 25 files changed, 439 insertions(+), 1126 deletions(-)
 delete mode 100644 net/tipc/log.h
