From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [PATCH 2.6.11.6-bk2] e100: Use EEPROM config for Auto MDI/MDI-X
Date: Thu, 31 Mar 2005 08:39:28 -0800
Message-ID: <468F3FDA28AA87429AD807992E22D07E04BFF982@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Netdev" <netdev@oss.sgi.com>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Linux NICS" <linuxnics@mailbox.cps.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261553AbVCaQj4@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Eran Mann" <emann@mrv.com>, "Jeff Garzik" <jgarzik@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eran:

Good catch. We will include this patch in the next release of our
driver.

Thanks,
Ganesh.

>-----Original Message-----
>From: Eran Mann [mailto:emann@mrv.com]
>Sent: Wednesday, March 30, 2005 5:42 AM
>To: Jeff Garzik
>Cc: Netdev; Linux Kernel; Linux NICS; Venkatesan, Ganesh
>Subject: [PATCH 2.6.11.6-bk2] e100: Use EEPROM config for Auto
MDI/MDI-X
>
>Current e100.c doesn't follow the EEPROM configuration regarding Auto
>MDI/MDI-X switching, instead it is enabled unconditionally for the
>relevant chips.
>This is especially bad since according to Intel's errata this feature
is
>no-longer supported.
>
>Signed-off-by: Eran Mann <emann@mrv.com>
