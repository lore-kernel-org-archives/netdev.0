From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 17:58:16 -0800
Message-ID: <50A2FAB8.8010803@intel.com>
References: <1352845788.6276.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <20121113.181600.667479923208656972.davem@davemloft.net> <1352850029.6276.52.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <20121113.202408.79469396824848499.davem@davemloft.net> <1352857850.6276.71.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10257 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756154Ab2KNB6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:58:46 -0500
In-Reply-To: <1352857850.6276.71.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2012 5:50 PM, Michael Chan wrote:
> On Tue, 2012-11-13 at 20:24 -0500, David Miller wrote:
>> From: "Michael Chan" <mchan@broadcom.com>
>> Date: Tue, 13 Nov 2012 15:40:29 -0800
>>
>>> I suppose we can just put the SAN MAC into the real netdev->dev_addr so
>>> that the VLAN will automatically get it.  But this doesn't seem very
>>> nice as we would be pretending to have a normal MAC address (for
>>> networking) in this SAN device.  The networking MAC address is in a
>>> different PCI function.
>>
>> I certainly would prefer if you took that approach.  At least in that
>> way the addressing of the netdev objects would appear more consistent.
>>
> Ok.  To be more complete, I think we need to add a flag or something to
> such a netdev to indicate that it is a SAN device only.  What's your
> opinion on that?

Michael, how do you determine a L2 packet is a SAN type? Do you have
ACLs in the FW/hardware to prevent other types of L2 traffic from being
sent? I guess I'm asking what makes it a SAN only device.

.John
