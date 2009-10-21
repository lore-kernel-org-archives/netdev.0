From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 1/3] irq: Export irq_set_affinity() for
	drivers
Date: Wed, 21 Oct 2009 16:35:54 +0100
Message-ID: <1256139354.2859.2.camel@achroite>
References: <20091021022626.32449.73883.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gospo@redhat.com, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56140 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbZJUPfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 11:35:52 -0400
In-Reply-To: <20091021022626.32449.73883.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-20 at 19:26 -0700, Jeff Kirsher wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> This patch allows drivers to specify an IRQ affinity mask for
> their respective interrupt sources.  This is very useful on
> network adapters using MSI-X, where aligning network flows
> linearly to CPUs greatly improves efficiency of the network
> stack.
[...]

Since this is not networking-specific, I think it needs to go to
linux-kernel as well.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

