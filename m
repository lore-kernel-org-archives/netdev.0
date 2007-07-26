From: Jeff Garzik <jeff@garzik.org>
Subject: ethtool version 6 released
Date: Thu, 26 Jul 2007 13:56:18 -0400
Message-ID: <46A8E042.3000807@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030502090706040702010300"
To: netdev <netdev@vger.kernel.org>,
	linux-net <linux-net@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49841 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935475AbXGZR4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 13:56:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030502090706040702010300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The yearly ethtool update is available (it doesn't see a lot of action) 
at its home page,

	http://sf.net/projects/gkernel/

or directly via git SCM:

	git://git.kernel.org/pub/scm/network/ethtool/ethtool.git

The release notes and full changelog (from git) are attached.

	Jeff



--------------030502090706040702010300
Content-Type: text/plain;
 name="relnotes.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="relnotes.txt"


Version 6 - July 26, 2007

	* Fix/security: Fix handling of statistics where the label
	  is exactly 32 bytes (ETH_GSTRING_LEN).
	* Feature: Add ability to change the advertised speed/duplex
	  to a different range of values, rather than all-or-one.
	* Feature: ixgb register dump support
	* Feature: sky2 register dump support
	* Feature: Fabric7 VIOC register dump support
	* Feature: Decode raw register dump stored in a file
	* Feature: Add ability to force hex register dump, if desired
	* Feature: update e1000 register dump
	* Feature: Additional 10Gbps support
	* Feature: Add 2.5G support
	* Feature: Update r8169 register dump
	* Feature: SMSC LAN911x/LAN921x register dump support
	* Cleanup: Update internal ethtool.h copy to match upstream
	  kernel 2.6.23-rc1 version of ethtool.h.


--------------030502090706040702010300
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

commit ee6a4ec9b23ae887d280f0f4eedb9a931f71d311
Author: Jeff Garzik <jeff@garzik.org>
Date:   Thu Jul 26 13:41:45 2007 -0400

    Release version 6.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit f45bb4faddffed6de1932105b17e28d48f9c3127
Author: Jeff Garzik <jeff@garzik.org>
Date:   Thu Jul 26 13:32:17 2007 -0400

    Update embedded copy of ethtool.h from kernel 2.6.23-rc1.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit ba2f54ba29ab2a9fee5529f161ce86215c3b1b0d
Author: Jeff Garzik <jeff@garzik.org>
Date:   Thu Jul 26 13:24:59 2007 -0400

    Trim trailing whitespace.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit a5f8ce23307719f03727f72f1d68007213de7d5c
Author: Steve Glendinning <steve.glendinning@smsc.com>
Date:   Mon Jul 16 20:04:40 2007 +0100

    ethtool: add register dump support for SMSC LAN911x/LAN921x
    
    This patch adds support for SMSC's LAN911x and LAN921x families of
    embedded ethernet controllers to ethtool's dump registers (-d) command.
    
    This patch is for use with the smsc911x driver.
    
    Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 3764dec8110409fd07def332732909ba84fec752
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Wed May 30 13:44:03 2007 +0200

    ethtool: new ID to decode the registers of the 8101E (realtek)
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit fed21029f02c970c6affaafa4a9294fce2775f40
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Thu May 24 22:02:42 2007 +0200

    ethtool: new ID to decode the registers of the 8168 (realtek)
    
    Tested with an Asrock 945G-DVI (LOM).
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 029cce110c4e5297bbe3f946868e32820e842856
Author: Michael Chan <mchan@broadcom.com>
Date:   Thu May 3 00:27:10 2007 -0700

    ethtool: Add 2.5G support
    
    Add 2.5G Serdes support to ethtool user program and ethtool.8 man
    page.  The missing pause bits are also added to keep ethtool-copy.h
    in sync with the kernel's version.
    
    Signed-off-by: Michael Chan <mchan@broadcom.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 06759c2e613e608038836d0ab7f21eb07570d355
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Wed Apr 4 13:41:16 2007 -0700

    ethtool: add 88e807X chip to decode
    
    Add decode for Yukon Extreme chip
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 9896cd5012e6c76cb5978da424888a06fa666ff4
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Wed Apr 4 13:40:15 2007 -0700

    ethtool: marvell chip version decode fix
    
    The chip revision wasn't being decoded properly.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit ec45cbae2eefffa770f5cf5729a0b5410963b7b8
Author: Rick Jones <rick.jones2@hp.com>
Date:   Wed Apr 4 17:33:08 2007 -0700

    ethtool: additional 10Gig niceness
    
    teach ethtool to print "10000Mb/s" for a 10G NIC and prepare
    for 10G NICs where it is possible to run something other than 10G
    update the ethtool.8 manpage with info re same and some grammar fixes
    
    Signed-off-by: Rick Jones <rick.jones2@hp.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 0be59452b155b2b79980d809fbcb435de4b6e799
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Wed Jan 31 16:23:46 2007 -0800

    marvell chip decode formatting
    
    Fix some typo's and formatting on Marvell ethtool output.
    If sync transmit queue is not used, don't print settings.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 96144b87a89d72eafb227a69103a74d49975fb44
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Fri Jan 19 14:49:57 2007 -0800

    e1000: update device ID table for register dumps
    
    e1000: update device ID table for register dumps with new devices
    
    From: Auke Kok <auke-jan.h.kok@intel.com>
    
    The register dump routine of e1000 was missing several newer chipsets. I
    reimported the mac detection code from the linux e1000 driver. This fixes
    newer NIC's reporting that their bus type is PCI instead of PCI-e.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 7764430a139e4a089127f5616b0d56f497be1036
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Thu Jan 11 15:36:10 2007 -0800

    ethtool: fix long statistics name
    
    Fix handling of statistics where the label is exactly 32 (ETH_GSTRING_LEN)
    characters long (observed with chelsio 10G driver).
    Before it would print garbage because of going by end
    of string. Don't need to copy string, just use formats properly.
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 5ab06db9d8777aef9307357b49d94cc267ba8105
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Mon Oct 23 10:58:37 2006 -0700

    ethtool: allow force hex in register dump
    
    Sometimes the device decode logic just gets in the way
    so add a "force hex" option to register dump.
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit fd3dc7be2449dc1b7950fcf22dbc2cf5a6504fa2
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Mon Oct 23 10:57:03 2006 -0700

    ethtool: flie option to register dump
    
    Add ability to take old raw dumps from a file and decode them.
    It is kind of limited because you still need to have same device
    as the raw file, but useful for maintainers to decode raw dumps.
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit b9caefa09afc12072e8beee0596be19384e7a21f
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Mon Oct 23 10:51:42 2006 -0700

    [PATCH] ethtool: marvell register dump
    
    This is a consolidation of earlier marvell register decode patches to ethtool.
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 12b0c64313c96d87dfc08254fd4e9544e45f5b18
Author: Sriram Chidambaram <schidambaram@fabric7.com>
Date:   Tue Oct 24 15:07:27 2006 -0700

    [PATCH] Fabric7 VIOC: Ethtool
    
    Removed debug print statement
    
    Signed-off-by: Fabric7 Driver-Support <driver-support@fabric7.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 8babd795f6bcbf9b21e31c43ce53bd0654974488
Author: Sriram Chidambaram <schidambaram@fabric7.com>
Date:   Tue Oct 24 14:30:41 2006 -0700

    [PATCH] Fabric7 VIOC: Ethtool
    
    Ethtool patch for Fabric7 VIOC Device Driver.
    
    Signed-off-by: Fabric7 Driver-Support <driver-support@fabric7.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit ee35083398b3497d627a14b51e97c23c243d4f6b
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Fri Oct 6 15:45:41 2006 -0700

    [PATCH] ethtool: sky2 more decode
    
    Add some more decoding of Rx FIFO bits
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit aa60a2982e3f9cdf1307c105cb9f298e0e10a99b
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Tue Sep 26 13:10:52 2006 -0700

    [PATCH] ethtool: spelling fix
    
    Fix my bogus spelling.
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit ad702599947629f096b698b6d0f9ba7f24b27cce
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Tue Sep 26 13:09:14 2006 -0700

    [PATCH] ethtool: sky2 support
    
    Add full support for sky2 chip
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 2d50690d76353f1a954f7f632e0894d124cc9241
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Tue Sep 26 13:08:25 2006 -0700

    [PATCH] ethtool: move skge.c to marvell.c
    
    The code will be common for skge and sky2
    
    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 6763e2b61d134ecb2b9c9732c25963e52afab54b
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Sep 19 15:05:55 2006 -0400

    ixgb: Trim trailing whitespace.

commit fb522ac8e761a669c88e03a9e23b4204a36217c7
Author: Nicholas Nunley <nicholas.d.nunley@intel.com>
Date:   Tue Sep 19 11:27:35 2006 -0700

    [PATCH] ethtool: add ixgb register dump support
    
    This adds support for dumping ixgb registers in readable format.
    
    Signed-off-by: Nicholas Nunley <nicholas.d.nunley@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit 5860312ac4ae67da856df19b31bd26ada6927955
Merge: 9fecbca... bfcb014...
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Sep 19 15:04:17 2006 -0400

    Merge branch 'e1000' of git://lost.foo-projects.org/~jtkirshe/ethtool into tmp

commit 9fecbca7a032cd644d76a8b35ae4fe743e7b2b16
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Fri Sep 8 16:13:30 2006 -0700

    [PATCH] ethtool: e1000: fix a typo
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

commit bfcb014b3b18dce0e3f744b0ad919eef47b9d25d
Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date:   Wed Sep 6 09:38:39 2006 -0700

    ethtool v5: add autoneg advertise feature
    
    adds the ability to change the advertised speed and duplex for a network interface.  Previously, a network interface was only able to advertise all supported speed's and duplex's, or one individual speed and duplex.  The feature allows the user to choose which supported speed's and duplex's to advertise by using the hex value.
    
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

--------------030502090706040702010300--
