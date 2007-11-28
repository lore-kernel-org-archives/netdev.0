From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH] e1000: Fix for 32 bits platforms with 64 bits resources
Date: Thu, 29 Nov 2007 06:52:12 +1100
Message-ID: <1196279532.13230.14.camel@pasglop>
References: <20071116073821.548CCDDDF4@ozlabs.org>
	 <36D9DB17C6DE9E40B059440DB8D95F5203DF7871@orsmsx418.amr.corp.intel.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jeff@garzik.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38484 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754695AbXK1Twh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 14:52:37 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5203DF7871@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-11-28 at 10:47 -0800, Brandeburg, Jesse wrote:
> 
> > The side effect is that I removed the assignments to the netdev
> > fields mem_start, mem_end and base_addr, which are totally useless
> > for PCI devices.
> 
> also, concerning this, ifconfig shows the output of these variables, I
> don't think we want to blatantly remove them, as it is actually removing
> information that is, if not used, at least displayed to user space.

It's not the right place to have that information and there is no
room in the user space field to fit more than 32 bits on 32 bits
platforms so I'd rather remove it. It's really only for ISA drivers that
have user configurable addresses.

Ben.


