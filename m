From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Thu, 14 Feb 2008 09:38:45 -0800
Message-ID: <1203010725.19205.44.camel@nimitz.home.sr71.net>
References: <200802111724.12416.ossthema@de.ibm.com>
	 <1202748429.8276.21.camel@nimitz.home.sr71.net>
	 <200802131617.58646.ossthema@de.ibm.com>
	 <OF64B9886B.CE795DED-ONC12573EF.002FFA8B-C12573EF.00301683@de.ibm.com>
	 <1203009163.19205.42.camel@nimitz.home.sr71.net>
	 <1203010575.12312.6.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <RAISCH@de.ibm.com>, ossthema@linux.vnet.ibm.com,
	apw <apw@uk.ibm.com>, Greg KH <greg@kroah.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	Thomas Q Klein <TKLEIN@de.ibm.com>, tklein@linux.ibm.com
To: Badari Pulavarty <pbadari@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:44920 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755033AbYBNRio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 12:38:44 -0500
In-Reply-To: <1203010575.12312.6.camel@dyn9047017100.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-02-14 at 09:36 -0800, Badari Pulavarty wrote:
> 
> I am not sure what you are trying to do with walk_memory_resource().
> The
> behavior is different on ppc64. Hotplug memory usage assumes that all
> the memory resources (all system memory, not just IOMEM) are
> represented
> in /proc/iomem. Its the case with i386 and ia64. But on ppc64 is
> contains ONLY iomem related. Paulus didn't want to export all the
> system
> memory into /proc/iomem on ppc64. So I had to workaround by providing
> arch-specific walk_memory_resource() function for ppc64.

OK, let's use that one.

-- Dave

