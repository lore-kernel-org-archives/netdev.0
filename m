From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Enable smsc911x for use with ACPI
Date: Thu, 13 Aug 2015 17:00:15 -0700 (PDT)
Message-ID: <20150813.170015.1983400219932580352.davem@davemloft.net>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	steve.glendinning@shawell.net, rafael.j.wysocki@intel.com,
	grant.likely@linaro.org, Suravee.Suthikulpanit@amd.com,
	Catalin.Marinas@arm.com
To: jeremy.linton@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932169AbbHNAAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 20:00:16 -0400
In-Reply-To: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Linton <jeremy.linton@arm.com>
Date: Wed, 12 Aug 2015 17:06:25 -0500

> This set of patches enables the front Ethernet port on the
> ARM Juno development platform when used with an ACPI enabled kernel.
> 
> These patches covert the of_property* calls in the driver to the
> DT/ACPI agnostic device_property* calls, and add the arm hardware
> id to the acpi_match_table.
> 
> To support the above changes I copied a couple routines from
> of_net into the properties.c file, and modified them to
> be ACPI/DT agnostic. I'm not 100% sure this is the correct location
> for these functions. But I think they are required to avoid having
> a dozen different implementations scattered across assorted Ethernet
> adapters that are being enabled to use ACPI properties.

I realize that there are still some rinkles to work out, but I applied
this patch series as-is to net-next, and any fixups should be
submitted as followups.

Thanks.
