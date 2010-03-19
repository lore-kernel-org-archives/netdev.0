From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 0/9] wireless: Use macros from wireless.h
Date: Thu, 18 Mar 2010 18:29:31 -0700
Message-ID: <cover.1268961559.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: orinoco-users@lists.sourceforge.net, Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	netdev@vger.kernel.org, orinoco-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Intel Linux Wireless <ilw@linux.intel.com>, linuxppc-dev@ozlabs.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Richard Kennedy <richard@rsk.demon.co.uk>,
	"David S. Miller" <davem@davemloft.net>, Pavel Roskin <proski@gnu.org>
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Create a IW_HANDLER macro for iw_handler array entries in wireless.h
Use the wireless.h macros in various wireless files
Use starting index define SIOCIWFIRST where appropriate 
Remove local #defines of IW_IOCTL
Remove STD_IW_HANDLER macro in orinoco, use IW_HANDLER instead

Joe Perches (9):
  include/linux/wireless.h: Add IW_HANDLER macro to initialize array entry
  wireless.h: Use SIOCIWFIRST not SIOCSIWCOMMIT for range check
  include/net/iw_handler.h: Use SIOCIWFIRST not SIOCSIWCOMMIT in comment
  net/wireless/wext_core.c: Use IW_IOCTL_IDX macro
  net/wireless/wext-core.c: Use IW_EVENT_IDX macro
  drivers/net/wireless: Use IW_HANDLER macro
  drivers/net: Remove local #define IW_IOCTL, use IW_HANDLER
  orinoco/wext.c: Remove local #define STD_IW_HANDLER
  drivers/net/wireless/ray_cs.c: Use iw_handler function prototypes

 drivers/net/ps3_gelic_wireless.c       |   35 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c |   83 ++++++-------
 drivers/net/wireless/orinoco/wext.c    |   94 +++++++-------
 drivers/net/wireless/ray_cs.c          |  212 +++++++++++++++-----------------
 drivers/net/wireless/wl3501_cs.c       |   52 ++++----
 include/linux/wireless.h               |    4 +-
 include/net/iw_handler.h               |    2 +-
 net/wireless/wext-core.c               |  134 ++++++++++----------
 8 files changed, 298 insertions(+), 318 deletions(-)
