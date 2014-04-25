From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 0/2] Use pci_enable_msix_range()
	instead of pci_enable_msix()
Date: Fri, 25 Apr 2014 10:06:23 +0200
Message-ID: <cover.1398412015.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, Shahed Shaikh <shahed.shaikh@qlogic.com>,
	e1000-devel@lists.sourceforge.net,
	Dept-HSGLinuxNICDev@qlogic.com, linux-pci@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alexander Gordeev <agordeev@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
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

Hello,

The series completes converison of network drivers to the new
MSI initialization API.

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range()  or pci_enable_msi_exact()
and pci_enable_msix_range() or pci_enable_msix_exact()
interfaces.

Thanks!

Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
Cc: Linux NICS <linux.nics@intel.com>
Cc: e1000-devel@lists.sourceforge.net
Cc: Dept-HSGLinuxNICDev@qlogic.com
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org

Alexander Gordeev (2):
  i40evf: Use pci_enable_msix_range() instead of pci_enable_msix()
  qlcnic: Use pci_enable_msix_exact() instead of pci_enable_msix()

 drivers/net/ethernet/intel/i40evf/i40evf_main.c  |   31 ++++++++--------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 +-
 2 files changed, 13 insertions(+), 22 deletions(-)

-- 
1.7.7.6


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
