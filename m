From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/9] drivers/net/s2io.c: Cleanups
Date: Mon, 24 Aug 2009 20:29:39 -0700
Message-ID: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a few cleanups, compiled, untested.  No hardware.

Joe Perches (9):
  s2io.c: Use const for strings
  s2io.c: Shorten code line length by using intermediate pointers
  s2io.c: Use calculated size in kmallocs
  s2io.c: use kzalloc
  s2io.c: Make more conforming to normal kernel style
  s2io.c: convert printks to pr_<level>
  s2io.c: fix spelling explaination
  s2io.c: Standardize statistics accessors
  s2io.c: Convert skipped nic->config.tx_cfg[i]. to tx_cfg->

 drivers/net/s2io.c | 3367 ++++++++++++++++++++++++++--------------------------
 1 files changed, 1695 insertions(+), 1672 deletions(-)
