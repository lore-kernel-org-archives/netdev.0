From: Zhang Rui <rui.zhang@intel.com>
Subject: Re: [PATCH] ACPI: export acpi events via generic netlink
Date: Thu, 05 Jul 2007 16:24:07 +0800
Message-ID: <1183623847.8961.45.camel@localhost.localdomain>
References: <1182224403.5411.84.camel@localhost.localdomain>
	 <200707031545.16787.lenb@kernel.org>
	 <1183550487.3812.14.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Len Brown <lenb@kernel.org>,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40811 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757329AbXGEIWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 04:22:24 -0400
In-Reply-To: <1183550487.3812.14.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-04 at 14:01 +0200, Johannes Berg wrote:
> On Tue, 2007-07-03 at 15:45 -0400, Len Brown wrote:
> > Thanks for including the demo program, Rui, it works for me (tm).
> > 
> > Applied -- with the incremental patch below, which I think
> > is correct because the only caller is bus.c, which is part of
> > the base kernel, not a module.

> Are you open to reworking this on top of my multicast patches that I
> hope to get in soonish, or should I respin my multicast patches to
> ensure ACPI has a stable family and multicast group number?
> 
Hi, Johannes,

I missed the discussion about the multicast issues.
You don't need to reserve a family and group ID for ACPI. I'll rework
this on your patches.:)

But I don't know when these mutlicast patches can be merged while I hope
the function of exporting ACPI event via genetlink can be added ASAP.

I'm okay to hold off on this patch if you think the multicast patches
can be merged soon. Or else I tend to apply it first and send an
additional patch together with your patches later.

Thanks,
Rui
