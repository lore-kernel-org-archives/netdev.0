From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [ANNOUNCE] e1000 to e1000e migration of PCI Express
	devices
Date: Fri, 04 Apr 2008 14:11:01 -0700
Message-ID: <47F69965.7030303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Greg KH <greg@kroah.com>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.m
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


All,

>From kernel 2.6.26 onward all *PCI Express* device IDs previously
supported by e1000 will be moving to the e1000e driver.  This includes
ich8 and ich9 onboard LAN, server 5000 platform onboard LAN (es2) and
82571/2/3 chipset based adapters and variants.

If you have not already enabled CONFIG_E1000E make sure that you do so.
You can already do this with 2.6.25.  From 2.6.26 on this change will be
required if you have such a device.

It is also worthwhile to note you will have to update your modprobe.conf
or equivalent file to point existing interfaces to the new driver.

For clarity, please note that all 8254x devices are only supported by
e1000, even if they are hidden behind a PCI Express bridge.  They are
still regular PCI or PCI-X devices.

Intel will continue to support both e1000 and e1000e drivers in the
kernel.


Regards,

Auke

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
