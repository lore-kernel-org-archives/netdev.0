From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [RFC 0/7] Fixing dma mask setting in various network
	drivers
Date: Tue, 11 Jun 2013 00:08:49 +0100
Message-ID: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Rasesh Mody <rmody@brocade.com>, Tushar Dave <tushar.n.dave@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

While looking at the way coherent DMA masks are handled (and the
fact many drivers write directly to the mask) I stumbled across
this set of oddities in various network drivers, which looks like
it's been cut'n'pasted.

I haven't yet tested these patches in any way, which is one reason
I'm sending them out as an RFC.  The other reason is to find out
if other people agree that these are indeed fixes.

 drivers/net/ethernet/brocade/bna/bnad.c           |    7 +++----
 drivers/net/ethernet/intel/e1000e/netdev.c        |   11 +++++------
 drivers/net/ethernet/intel/igb/igb_main.c         |   11 +++++------
 drivers/net/ethernet/intel/igbvf/netdev.c         |   11 +++++------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    9 ++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   11 +++++------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++++------
 7 files changed, 32 insertions(+), 39 deletions(-)

The full patchset will be sent to netdev only, the remainder will
be Cc'd depending on the individual driver being modified.  Each
patch is independent of each other.

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
