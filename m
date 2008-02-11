From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Mon, 11 Feb 2008 08:50:25 -0800
Message-ID: <1202748625.8276.24.camel@nimitz.home.sr71.net>
References: <200802111724.12416.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	"Themann, Jan-Bernd" <themann@de.ibm.com>,
	Greg KH <greg@kroah.com>, Christoph Raisch <RAISCH@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:41552 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751046AbYBKQu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:50:27 -0500
In-Reply-To: <200802111724.12416.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-11 at 17:24 +0100, Jan-Bernd Themann wrote:
> Drivers like eHEA need memory notifiers in order to 
> update their internal DMA memory map when memory is added
> to or removed from the system.
> 
> Patch for eHEA memory hotplug support that uses these functions:
> http://www.spinics.net/lists/netdev/msg54484.html
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

How about you fix up the driver, first?  Then, this can go in.

-- Dave

