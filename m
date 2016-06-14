From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 16:12:50 -0500
Message-ID: <57607352.4020900@arm.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33369 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912AbcFNVMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 17:12:52 -0400
In-Reply-To: <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 03:44 PM, Sergei Shtylyov wrote:
> On 06/14/2016 07:16 PM, Jeremy Linton wrote:
>
>> If the interrupt configuration isn't set and we are using the
>
>     It's never set, judging by the driver code.

	AFAIK, I think that its set when the device is configured as a platform 
device, or there is an external phy/interrupt setup in DT. I might be 
wrong on that..



>
>> internal phy, then we need to poll the phy to reliably detect
>> phy state changes.
>
>     What address your internal PHY is at? Mine is at 1, and things seem
> to work reliably after probing:
>
> SMSC LAN8700 18000000.etherne:01: attached PHY driver [SMSC LAN8700]
> (mii_bus:phy_addr=18000000.etherne:01, irq=-1)
>
>     I'm using the device tree on my board.
>
> MBR, Sergei
>
