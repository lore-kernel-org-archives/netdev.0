From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [patch netdev-2.6] e1000: add MODULE_VERSION
Date: Thu, 31 Mar 2005 08:42:57 -0800
Message-ID: <468F3FDA28AA87429AD807992E22D07E04BFF9A7@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@oss.sgi.com>, <jgarzik@pobox.com>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261555AbVCaQnZ@vger.kernel.org>
Content-class: urn:content-classes:message
To: "John W. Linville" <linville@tuxdriver.com>,
	<linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John:

We will include this in the next release of our driver.

Thanks,
Ganesh.

>-----Original Message-----
>From: John W. Linville [mailto:linville@tuxdriver.com]
>Sent: Wednesday, March 30, 2005 10:44 AM
>To: linux-kernel@vger.kernel.org
>Cc: netdev@oss.sgi.com; jgarzik@pobox.com; Veeraiyan, Ayyappan;
Ronciak,
>John; Venkatesan, Ganesh
>Subject: [patch netdev-2.6] e1000: add MODULE_VERSION
>
>Add MODULE_VERSION entry.
>
>Signed-off-by: John W. Linville <linville@tuxdriver.com>
>---
>I posted one like this before, but it seems to have been lost or
>overwritten...
>
> drivers/net/e1000/e1000_main.c |    4 +++-
> 1 files changed, 3 insertions(+), 1 deletion(-)
>
>--- netdev-2.6/drivers/net/e1000/e1000_main.c.orig	2005-03-30
>13:30:02.355409590 -0500
>+++ netdev-2.6/drivers/net/e1000/e1000_main.c	2005-03-30
>13:31:13.174846755 -0500
>@@ -65,7 +65,8 @@ char e1000_driver_string[] = "Intel(R) P
> #else
> #define DRIVERNAPI "-NAPI"
> #endif
>-char e1000_driver_version[] = "5.7.6-k2"DRIVERNAPI;
>+#define DRV_VERSION "5.7.6-k2"DRIVERNAPI
>+char e1000_driver_version[] = DRV_VERSION;
> char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
>
> /* e1000_pci_tbl - PCI Device ID Table
>@@ -210,6 +211,7 @@ static struct pci_driver e1000_driver =
> MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
> MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
> MODULE_LICENSE("GPL");
>+MODULE_VERSION(DRV_VERSION);
>
> static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
> module_param(debug, int, 0);
>--
>John W. Linville
>linville@tuxdriver.com
