From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/3] tipc: two cleanups, plus overload respin
Date: Fri, 15 Feb 2013 17:57:44 -0500
Message-ID: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60956 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab3BOW6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 17:58:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two relatively small cleanup patches here, plus a reimplementation
of the patch Neil had questions about[1] in the last development
cycle.

Tested on today's net-next, between 32 and 64 bit x86 machines using
the server/client in tipc-utils, as usual.

[1] http://patchwork.ozlabs.org/patch/204507/

Thanks,
Paul.

Cc: Neil Horman <nhorman@tuxdriver.com>
---

The following changes since commit d887199dc28c46788b155b234274d5ff41afed8e:

  tg3: Update version to 3.130 (2013-02-15 14:02:59 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to 97f8b87e9108485a0b7070645662253561304458:

  tipc: remove redundant checking for the number of iovecs in a send request (2013-02-15 17:03:32 -0500)

----------------------------------------------------------------
Ying Xue (3):
      tipc: eliminate duplicated discard_rx_queue routine
      tipc: byte-based overload control on socket receive queue
      tipc: remove redundant checking for the number of iovecs in a send request

 net/tipc/socket.c | 103 +++++++++++++++++++++++-------------------------------
 1 file changed, 44 insertions(+), 59 deletions(-)
