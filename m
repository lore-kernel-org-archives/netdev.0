From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000, e1000e valid-addr fixes
Date: Thu, 01 Nov 2007 15:31:21 -0400
Message-ID: <472A2989.2060603@garzik.org>
References: <20071023.145339.55504234.davem@davemloft.net>	<471E9801.2000006@garzik.org>	<471E99E8.6030404@garzik.org>	<20071023.180744.115914004.davem@davemloft.net>	<471EABEE.8030900@garzik.org> <20071101111157.7f3e4f58@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	davej@redhat.com, auke-jan.h.kok@intel.com, ajax@redhat.com,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58417 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627AbXKATb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 15:31:29 -0400
In-Reply-To: <20071101111157.7f3e4f58@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> How about:
> 
> static int eth_validate_addr(const struct net_device *dev)
> {
> 	return is_valid_ether_addr(dev->dev_addr) ? 0 : -EINVAL;
> }

hmmm -- its a slow path, so I don't see the value of marking the 
argument 'const' -- right now this implementation merely reads the 
dev->dev_addr[], but that need not always be the case.

And I don't see the value of squashing everything onto one line, IMO the 
current version is more readable.

	Jeff



