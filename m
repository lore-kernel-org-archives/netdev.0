From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 22 May 2007 14:10:59 +0400
Message-ID: <20070522101059.GA2394@2ka.mipt.ru>
References: <1179827251.7707.29.camel@localhost.localdomain> <1HPWB1js.1179828300.1901360.samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: rui.zhang@intel.com, linux-acpi@vger.kernel.org,
	"lenb@kernel.org" <lenb@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46939 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757298AbXEVKMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 06:12:36 -0400
Content-Disposition: inline
In-Reply-To: <1HPWB1js.1179828300.1901360.samuel@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 22, 2007 at 10:05:00AM -0000, Samuel Ortiz (samuel@sortiz.org) wrote:
> 
> On 5/22/2007, "Zhang Rui" <rui.zhang@intel.com> wrote:
> >Index: linux-2.6.22-rc1/include/linux/netlink.h
> >===================================================================
> >--- linux-2.6.22-rc1.orig/include/linux/netlink.h	2007-05-21 10:19:00.000000000 +0800
> >+++ linux-2.6.22-rc1/include/linux/netlink.h	2007-05-21 15:26:14.000000000 +0800
> >@@ -24,6 +24,7 @@
> > /* leave room for NETLINK_DM (DM Events) */
> > #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
> > #define NETLINK_ECRYPTFS	19
> >+#define NETLINK_ACPI_EVENT	20	/* acpi event notifications */
> I think it is recommended to use the generic netlink layer instead of
> having everyone adding its own netlink ID.

It is possible to allocate your own netlink protocol number, but Samuel
is right, it is better to use existing delivery mechanisms like
genetlink and connector.

> Cheers,
> Samuel.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
