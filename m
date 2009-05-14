From: Frans Pop <elendil@planet.nl>
Subject: [2.6.30] e1000e: pci_enable_pcie_error_reporting
	failed 0xfffffffb
Date: Thu, 14 May 2009 13:12:35 +0200
Message-ID: <200905141312.35945.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_jy/CKFvWxGFJHj8"
Cc: e1000-devel@lists.sourceforge.net, linux-pm@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Netdev <netdev@vger.kernel.org>
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

--Boundary-00=_jy/CKFvWxGFJHj8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

With 2.6.30-rc[45] I'm always seeing this error while resuming from STR on 
my HP 2510p notebook:

  e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
! e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed 0xfffffffb
  e1000e 0000:00:19.0: setting latency timer to 64
  e1000e 0000:00:19.0: wake-up capability disabled by ACPI
  e1000e 0000:00:19.0: PME# disabled
  e1000e 0000:00:19.0: wake-up capability disabled by ACPI
  e1000e 0000:00:19.0: PME# disabled
  e1000e 0000:00:19.0: irq 26 for MSI/MSI-X

The error only shows up during resume, not during normal boot.

With 2.6.29 the error is not present. Is this something that should be 
looked into? Networking still comes up normally.

Attached a full diff for a suspend/resume cycle with .29.3 and .30-rc5.

Cheers,
FJP


--Boundary-00=_jy/CKFvWxGFJHj8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
--Boundary-00=_jy/CKFvWxGFJHj8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--Boundary-00=_jy/CKFvWxGFJHj8--
