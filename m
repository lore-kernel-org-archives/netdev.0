From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: New pci-express e1000 driver (currently for ICH9
 devices only)
Date: Mon, 06 Aug 2007 14:57:08 -0700
Message-ID: <46B79934.8010405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64634 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756513AbXHFV5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 17:57:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



All,

Another update on e1000e. Many thanks to Jeff for helping out and getting this 
going forward. The driver is unfortunately still too large to post, so please 
use the URL's below to review:

   http://foo-projects.org/~sofar/e1000e-20070806.patch     [525k]
   http://foo-projects.org/~sofar/e1000e-20070806.patch.bz2  [90k]

   git://lost.foo-projects.org/~ahkok/git/linux-2.6 e1000e-20070806

Please note that the non-ICH9 device IDs are disabled, but this driver will 
(once you put them back in) properly work with all the current pci-e adapters 
that e1000 supports. Once this driver gets merged we'll move those devices over 
one by one.

Cheers,

Auke



---
From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Mon, 6 Aug 2007 14:14:44 -0700
Subject: [PATCH] e1000e: New pci-express e1000 driver (currently for ICH9 
devices only)

This driver implements support for the ICH9 on-board LAN ethernet
device. The device is similar to ICH8.

The driver encompasses code to support 82571/2/3, es2lan and ICH8
devices as well, but those device IDs are disabled and will be
"lifted" from the e1000 driver over one at a time once this driver
receives some more live time.

Changes to the last snapshot posted are exclusively in the internal
hardware API organization. Many thanks to Jeff Garzik for jumping in
and getting this organized with a keen eye on the future layout.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---
  drivers/net/Kconfig          |   23 +
  drivers/net/Makefile         |    1 +
  drivers/net/e1000e/82571.c   | 1382 +++++++++++++
  drivers/net/e1000e/Makefile  |   37 +
  drivers/net/e1000e/defines.h |  738 +++++++
  drivers/net/e1000e/e1000.h   |  518 +++++
  drivers/net/e1000e/es2lan.c  | 1255 ++++++++++++
  drivers/net/e1000e/ethtool.c | 1763 +++++++++++++++++
  drivers/net/e1000e/hw.h      |  862 +++++++++
  drivers/net/e1000e/ich8lan.c | 2297 ++++++++++++++++++++++
  drivers/net/e1000e/lib.c     | 2528 ++++++++++++++++++++++++
  drivers/net/e1000e/netdev.c  | 4413 ++++++++++++++++++++++++++++++++++++++++++
  drivers/net/e1000e/param.c   |  382 ++++
  drivers/net/e1000e/phy.c     | 1821 +++++++++++++++++
  14 files changed, 18020 insertions(+), 0 deletions(-)
  create mode 100644 drivers/net/e1000e/82571.c
  create mode 100644 drivers/net/e1000e/Makefile
  create mode 100644 drivers/net/e1000e/defines.h
  create mode 100644 drivers/net/e1000e/e1000.h
  create mode 100644 drivers/net/e1000e/es2lan.c
  create mode 100644 drivers/net/e1000e/ethtool.c
  create mode 100644 drivers/net/e1000e/hw.h
  create mode 100644 drivers/net/e1000e/ich8lan.c
  create mode 100644 drivers/net/e1000e/lib.c
  create mode 100644 drivers/net/e1000e/netdev.c
  create mode 100644 drivers/net/e1000e/param.c
  create mode 100644 drivers/net/e1000e/phy.c
