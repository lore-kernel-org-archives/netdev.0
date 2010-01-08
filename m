From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] dmfe/tulip: Let dmfe handle DM910x except for SPARC
 on-board chips
Date: Thu, 07 Jan 2010 17:27:57 -0800 (PST)
Message-ID: <20100107.172757.144374579.davem@davemloft.net>
References: <20100107.010651.18296756.davem@davemloft.net>
	<1262868111.2377.55.camel@localhost>
	<20100107184624.GA9534@lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, brandon@ifup.org, grundler@google.com,
	tobias@ringis.se, kyle@mcmartin.ca, netdev@vger.kernel.org
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35000
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751280Ab0AHB1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 20:27:49 -0500
In-Reply-To: <20100107184624.GA9534@lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>
Date: Thu, 7 Jan 2010 11:46:24 -0700

> On Thu, Jan 07, 2010 at 12:41:51PM +0000, Ben Hutchings wrote:
>> The Davicom DM9100 and DM9102 chips are used on the motherboards of
>> some SPARC systems (supported by the tulip driver) and also in PCI
>> expansion cards (supported by the dmfe driver).  There is no
>> difference in the PCI device ids for the two different configurations,
>> so these drivers both claim the device ids.  However, it is possible
>> to distinguish the two configurations by the presence of Open Firmware
>> properties for them, so we do that.
>> 
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

Applied.
