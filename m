From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 18:30:05 -0400
Message-ID: <466F1E6D.8070401@garzik.org>
References: <20070612.140240.00078635.davem@davemloft.net>	<466F0C92.5080306@garzik.org>	<466F0D78.7090404@candelatech.com> <20070612.142658.45082832.davem@davemloft.net> <466F144A.3070809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58976 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755132AbXFLWaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 18:30:10 -0400
In-Reply-To: <466F144A.3070809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> That sounds plausible for many uses, but it may also be useful to have
> the virtual devices.  Having 802.1Q VLANs be 'real' devices has worked out
> quite well, so I think there is a place for a 'mac-vlan' as well.

Virtual devices are pretty much the only solution we have right now, 
both in terms of available control points, and in terms of mapping to 
similar existing solutions (like wireless and its multiple net devices).

	Jeff


