From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/8] tipc: add tipc_ prefix to various structs
Date: Thu, 29 Dec 2011 22:48:49 -0500
Message-ID: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63602 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979Ab1L3DtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here is the addition of the tipc_ prefix that you requested earlier
this week.  I left the changes as separate commits since it makes it
easier at a glance to review them and make sure my regex foo did
the right thing in each case.  The last commit intentionally adds
an "s" [i.e. name --> names] since that better describes what the
struct actually contains.

I didn't redo runtime testing, but it is compile tested as a sanity
check.  Long lines caused by the addition of the prefix have been
wrapped so the patches are (as usual) checkpatch clean.

Happy New Year!
Paul.

---

The following changes since commit d191854282fd831da785a5a34bc6fd16049b8578:

  ipv6: Kill rt6i_dev and rt6i_expires defines. (2011-12-28 20:19:20 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc-Dec29-2011

Paul Gortmaker (8):
  tipc: rename struct media to struct tipc_media
  tipc: rename struct port_list to struct tipc_port_list
  tipc: rename struct subscription to struct tipc_subscription
  tipc: rename struct subscriber to struct tipc_subscriber
  tipc: rename struct bclink to struct tipc_bclink
  tipc: rename struct bcbearer* to tipc_bcbearer*
  tipc: rename struct link* to struct tipc_link*
  tipc: rename struct bearer_name to struct tipc_bearer_names

 net/tipc/bcast.c      |   46 +++++++-------
 net/tipc/bcast.h      |   10 ++--
 net/tipc/bearer.c     |   42 +++++++------
 net/tipc/bearer.h     |   23 ++++----
 net/tipc/discover.c   |   20 +++---
 net/tipc/discover.h   |    8 +-
 net/tipc/eth_media.c  |    4 +-
 net/tipc/link.c       |  155 +++++++++++++++++++++++++------------------------
 net/tipc/link.h       |   52 +++++++++--------
 net/tipc/name_distr.c |    2 +-
 net/tipc/name_table.c |   15 +++--
 net/tipc/name_table.h |   10 ++--
 net/tipc/node.c       |   18 +++---
 net/tipc/node.h       |   12 ++--
 net/tipc/port.c       |    8 +-
 net/tipc/port.h       |    4 +-
 net/tipc/subscr.c     |   46 +++++++-------
 net/tipc/subscr.h     |   10 ++--
 18 files changed, 248 insertions(+), 237 deletions(-)

-- 
1.7.4.4
