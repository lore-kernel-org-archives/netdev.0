From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/2] HW VLAN filtering control
Date: Fri, 27 Jul 2007 14:06:23 -0700
Message-ID: <46AA5E4F.4090005@candelatech.com>
References: <1185569723.28574.8.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39111 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934323AbXG0VGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 17:06:25 -0400
In-Reply-To: <1185569723.28574.8.camel@strongmad>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitch Williams wrote:
> This patchset adds the capability to disable hardware VLAN filtering at
> runtime via the existing vconfig utility.  It's useful for debugging
> purposes.
> 
> The first patch modifies the VLAN subsystem to define the flag, and to
> support passing the flag on to the base driver.
> 
> The second patch modifies e1000 to support the flag.  Since it's only
> one function, other drivers can be easily modified to support this
> functionality.
> 
> vconfig is used without modification to enable or disable filtering:
> 	# vconfig [vlan-interface] 2 1
> will disable filtering, and
> 	# vconfig [vlan-interface] 2 0
> will enable filtering.

This looks fine to me.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

