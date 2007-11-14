From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 5/6] e1000: Secondary unicast address support
Date: Tue, 13 Nov 2007 17:05:27 -0800
Message-ID: <473A49D7.2020400@candelatech.com>
References: <20071113231110.13177.27339.stgit@localhost.localdomain> <20071113231133.13177.84769.stgit@localhost.localdomain> <Pine.LNX.4.64.0711140113400.15397@bizon.gios.gov.pl> <473A3EE9.4040700@candelatech.com> <Pine.LNX.4.64.0711140141320.15397@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34738 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763672AbXKNBFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 20:05:47 -0500
In-Reply-To: <Pine.LNX.4.64.0711140141320.15397@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:

> I'm afraid mac-vlans is not a solution here. Having 2x more interfaces 
> (ex. 2000 instead of 1000) makes everything (especially routing, 
> firewalling and QoS) much more complicated. It would be nice to have 
> something like "ip addr add a.b.c.d/24 dev vlan32 hwaddress 
> aa:bb:cc:dd:ee:ff".

I'll take your word for it, though I have had good luck using mac-vlans
in my own app.  They are nice because the are full-fledged interfaces,
so you can treat them basically as .1q vlans or ethernet devices, including
all the routing and firewalling tricks.

> BTW: is it possible to stack mac-vlans ontop of .1Q vlans?

I believe it will work fine.  You could probably also stack .1q
VLANs on top of mac-vlans so long as you use the same MAC for the VLANs as for
the mac-vlan dev.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

