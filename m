From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Wed, 28 Sep 2011 00:45:46 +0100
Message-ID: <1317167146.2845.48.camel@bwh-desktop>
References: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
	 <1316477404.14749.256.camel@deadeye>
	 <20110920185918.GX21309@gospo.rdu.redhat.com>
	 <20110920202305.GC16323@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, Alexander H Duyck <alexander.h.duyck@intel.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:22077 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab1I0Xpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 19:45:50 -0400
In-Reply-To: <20110920202305.GC16323@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-20 at 16:23 -0400, Neil Horman wrote:
[...]
> This is the work Andy is referring to for those interested:
> http://marc.info/?l=linux-kernel&m=131644727521409&w=2
> 
> This version has Gregs Ack, and is waiting for an Ack from Jesse Barnes at the
> moment.

While I think it's useful to be able to list all IRQs assigned to a PCI
device, this doesn't tell us anything about the way they're associated
with queues.

> I think Andy's probably right, theres room here for expansion to create
> a relationship between a given interrupt and a napi wieght.  I expect what would
> be most direct would be adding a napi_weight attribute that was conditional on
> the class of the pci device allocating the irqs (make it visible for class 0x200
> devs, invisible for others).

That's a terrible idea; what has NAPI got to do with PCI devices?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
