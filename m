From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/7] drivers/net: Use netif_<level>
	macros
Date: Mon, 15 Feb 2010 10:34:19 -0800
Message-ID: <cover.1266258417.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Don Fry <pcnet32@verizon.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Alexander Indenbaum <baum@tehutinetworks.net>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

And a few checkpatch cleanups

Joe Perches (7):
  drivers/net/ixgb: Use netif_printk macros
  drivers/net/sky2: Convert to use netif_printk macros
  drivers/net/tehuti.c: Use (pr|netdev|netif)_<levels> macro helpers
  drivers/net/tehuti.c: Hoist assigns out of ifs
  drivers/net/tehuti.c: trivial checkpatch cleanups
  drivers/net/pcnet32.c: Use (pr|netdev|netif)_<levels> macro helpers
  drivers/net/pcnet32.c: Checkpatch cleaning

 drivers/net/ixgb/ixgb.h      |   11 +-
 drivers/net/ixgb/ixgb_main.c |   89 ++++----
 drivers/net/pcnet32.c        |  500 +++++++++++++++++-------------------------
 drivers/net/sky2.c           |   65 +++----
 drivers/net/tehuti.c         |  151 +++++++-------
 drivers/net/tehuti.h         |   30 ++-
 6 files changed, 374 insertions(+), 472 deletions(-)


------------------------------------------------------------------------------
SOLARIS 10 is the OS for Data Centers - provides features such as DTrace,
Predictive Self Healing and Award Winning ZFS. Get Solaris 10 NOW
http://p.sf.net/sfu/solaris-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
