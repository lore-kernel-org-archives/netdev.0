From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 0/2] seq: Convert seq_puts and seq_putc to return void
Date: Mon, 10 Nov 2014 10:58:55 -0800
Message-ID: <cover.1415645476.git.joe@perches.com>
Cc: Petr Mladek <pmladek@suse.cz>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>,
	openipmi-developer@lists.sourceforge.net,
	linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are error prone, so return void adn use seq_has_overflowed instead

Joe Perches (2):
  seq_puts: Convert to return void and convert uses too.
  seq_putc: Convert to return void and convert uses too.

 drivers/char/ipmi/ipmi_msghandler.c                |  4 +-
 drivers/parisc/ccio-dma.c                          |  7 +-
 drivers/regulator/dbx500-prcmu.c                   | 21 ++----
 drivers/usb/gadget/udc/goku_udc.c                  | 81 +++++++++++-----------
 drivers/watchdog/bcm_kona_wdt.c                    | 43 +++++++-----
 fs/seq_file.c                                      | 26 +++----
 include/linux/seq_file.h                           |  4 +-
 ipc/util.c                                         |  6 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |  4 +-
 net/netfilter/nf_conntrack_expect.c                |  4 +-
 10 files changed, 105 insertions(+), 95 deletions(-)

-- 
2.1.2

