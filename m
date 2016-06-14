From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 15:48:50 -0500
Message-ID: <57606DB2.5030602@arm.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <20160614184236.GB8518@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33231 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbcFNUsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 16:48:52 -0400
In-Reply-To: <20160614184236.GB8518@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 01:42 PM, Andrew Lunn wrote:
> On Tue, Jun 14, 2016 at 11:16:02AM -0500, Jeremy Linton wrote:
>> If the interrupt configuration isn't set and we are using the
>> internal phy, then we need to poll the phy to reliably detect
>> phy state changes.
>
> Hi Jeremy
>  Why does the external phy not have the exact same problem?

Hello,

It may... but I've only got a fairly limited hardware testing setup, and 
this driver is used across a pretty broad set of hardware configured in 
various ways. So, I'm trying to limit the scope of things I might break. 
Initially I thought it was added to avoid a QEMU issue, but now I don't 
think that is the case.

So, if 0 can't be an interrupt why not update phy_interrupt_is_valid() 
to check for it? That would fix the problem too...
