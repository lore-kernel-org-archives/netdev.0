From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] decnet: Move to staging
Date: Mon, 22 Nov 2010 21:19:23 -0800 (PST)
Message-ID: <20101122.211923.193717252.davem@davemloft.net>
References: <1290484313.6770.1328.camel@localhost>
	<20101122203131.7cbd604b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, gregkh@suse.de, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, debian-kernel@lists.debian.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53883
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751037Ab0KWFS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 00:18:59 -0500
In-Reply-To: <20101122203131.7cbd604b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 22 Nov 2010 20:31:31 -0800

> On Tue, 23 Nov 2010 03:51:53 +0000
> Ben Hutchings <ben@decadent.org.uk> wrote:
> 
>> Recent review has revealed several bugs in obscure protocol
>> implementations that can be exploited by local users for denial of
>> service or privilege escalation.
>> 
>> The decnet protocol (PF_DECnet) is unmaintained.  Since 2.6.12-rc2 the
>> only changes appear to be adjustments for net API changes and fixes
>> for bugs found by inspection.
>> 
>> This protocol generally should not be enabled by distributions, since
>> the cost of a security flaw affecting all installed systems presumably
>> outweighs the benefit to the few (if any) legitimate users.
>> 
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> 
> NAK there are still users and stuff does get fixed.
> If you don't like it then disable it from config.

Seriously, I can't even remember a bonifides security flaw in decnet
being found recently and in fact the decnet stack is very well written
code.
