From: David Miller <davem@davemloft.net>
Subject: Re: [NET 02/06]: Introduce RTA_TABLE/FRA_TABLE attributes
Date: Thu, 10 Aug 2006 23:09:59 -0700 (PDT)
Message-ID: <20060810.230959.66804631.davem@davemloft.net>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
	<20060810193000.14867.49807.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35013
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751563AbWHKGJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:09:50 -0400
To: kaber@trash.net
In-Reply-To: <20060810193000.14867.49807.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 10 Aug 2006 21:30:00 +0200 (MEST)

> [NET]: Introduce RTA_TABLE/FRA_TABLE attributes
> 
> Introduce RTA_TABLE route attribute and FRA_TABLE routing rule attribute
> to hold 32 bit routing table IDs. Usespace compatibility is provided by
> continuing to accept and send the rtm_table field, but because of its
> limited size it can only carry the low 8 bits of the table ID. This
> implies that if larger IDs are used, _all_ userspace programs using them
> need to use RTA_TABLE.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
