From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [GIT PULL] ARCNET: refactoring and cleanup
Date: Tue, 22 Sep 2015 11:01:41 +0200
Message-ID: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43713 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932453AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 1f93e4a96c9109378204c147b3eec0d0e8100fde:

  Linux 4.3-rc2 (2015-09-20 14:32:34 -0700)

are available in the git repository at:

  git://git.pengutronix.de/git/mgr/linux.git tags/arcnet-cleanup-v4.3-rc2

for you to fetch changes up to 9ac23e159ab81450d7c644b13a271b514d2bcc23:

  arcnet: capmode: remove extra function (2015-09-21 16:36:30 +0200)

----------------------------------------------------------------
ARCNET: refactoring and cleanup

This series cleans up the code in drivers/net/arcnet
and include/uapi/linux/if_arcnet.h . It doesn't change
the runtime behaviour of the code. Its only purpose
is to improve the code maintenance and readability.

----------------------------------------------------------------
Joe Perches (29):
  arcnet: fix indentation of if_arcnet.h
  arcnet: Use normal kernel spacing style
  arcnet: Add and remove blank lines
  arcnet: Use normal kernel brace style
  arcnet: Coalesce string fragments
  arcnet: Use include/linux path for asm
  arcnet: Use network block comment style
  arcnet: Neaten BUGMSG macro defines
  arcnet: Expand odd BUGLVL macro with if and uses
  arcnet: Convert BUGMSG and BUGMSG2 to arc_prink and arc_cont
  arcnet: Convert printk to pr_<level>
  arcnet: Move EXPORT_SYMBOL after declarations
  arcnet: Remove unnecessary OOM messages
  arcnet: Remove assignments from ifs
  arcnet: Remove pointer comparisons to NULL
  arcnet: Convert arcnet_dump_skb macro to static inline
  arcnet: Wrap some long lines
  arcnet: Move files out of include/linux
  arcnet: Make a char * array const char * const
  arcnet: Add arcnet_<I/O> macros
  arcnet: com20020: Use arcnet_<I/O> routines
  arcnet: com90io: Use arcnet_<I/O> routines
  arcnet: com90xx: Use arcnet_<I/O> routines
  arcnet: arcdevice.h: Add arcnet_readb and arcnet_writeb
  arcnet: arc-rimi: Use arcnet_<I/O> routines
  arcnet: com90xx: Use arcnet_readb/writeb routines
  arcnet: Remove function pointer macro indirections
  arcnet: Add com9026.h to standardize COM9026_REG_<foo>
  arcnet: Remove unused arcnet_<I/O>w macros

Michael Grzeschik (4):
  arcnet: reformat structs to C99 format
  arcnet: com20020: replace magic numbers with readable macros
  arcnet: arc-rawmode: reorder module functions
  arcnet: capmode: remove extra function

 MAINTAINERS                                       |   1 -
 drivers/net/arcnet/arc-rawmode.c                  | 142 +++--
 drivers/net/arcnet/arc-rimi.c                     | 145 +++---
 {include/linux => drivers/net/arcnet}/arcdevice.h | 152 +++---
 drivers/net/arcnet/arcnet.c                       | 601 ++++++++++------------
 drivers/net/arcnet/capmode.c                      | 138 +++--
 drivers/net/arcnet/com20020-isa.c                 |  54 +-
 drivers/net/arcnet/com20020-pci.c                 |  70 ++-
 drivers/net/arcnet/com20020.c                     | 234 +++++----
 {include/linux => drivers/net/arcnet}/com20020.h  |  75 +--
 drivers/net/arcnet/com20020_cs.c                  | 325 ++++++------
 drivers/net/arcnet/com9026.h                      |  17 +
 drivers/net/arcnet/com90io.c                      | 209 ++++----
 drivers/net/arcnet/com90xx.c                      | 323 ++++++------
 drivers/net/arcnet/rfc1051.c                      |  77 ++-
 drivers/net/arcnet/rfc1201.c                      | 238 ++++-----
 include/uapi/linux/if_arcnet.h                    |  55 +-
 17 files changed, 1410 insertions(+), 1446 deletions(-)
 rename {include/linux => drivers/net/arcnet}/arcdevice.h (79%)
 rename {include/linux => drivers/net/arcnet}/com20020.h (61%)
 create mode 100644 drivers/net/arcnet/com9026.h

-- 
2.5.1
