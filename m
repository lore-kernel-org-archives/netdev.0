From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: Re: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: 22 May 2007 10:05:00 -0000
Message-ID: <1HPWB1js.1179828300.1901360.samuel@sortiz.org>
References: <1179827251.7707.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "lenb@kernel.org" <lenb@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: rui.zhang@intel.com, linux-acpi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([213.186.37.103]:51331 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755004AbXEVKFV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 06:05:21 -0400
In-Reply-To: <1179827251.7707.29.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 5/22/2007, "Zhang Rui" <rui.zhang@intel.com> wrote:
>Index: linux-2.6.22-rc1/include/linux/netlink.h
>===================================================================
>--- linux-2.6.22-rc1.orig/include/linux/netlink.h	2007-05-21 10:19:00.000000000 +0800
>+++ linux-2.6.22-rc1/include/linux/netlink.h	2007-05-21 15:26:14.000000000 +0800
>@@ -24,6 +24,7 @@
> /* leave room for NETLINK_DM (DM Events) */
> #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
> #define NETLINK_ECRYPTFS	19
>+#define NETLINK_ACPI_EVENT	20	/* acpi event notifications */
I think it is recommended to use the generic netlink layer instead of
having everyone adding its own netlink ID.

Cheers,
Samuel.
