From: David Miller <davem@davemloft.net>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 14:35:35 -0700 (PDT)
Message-ID: <20071101.143535.45402283.davem@davemloft.net>
References: <47292A99.5070805@linux-foundation.org>
	<20071031.215025.195350296.davem@davemloft.net>
	<4729EAFF.9050606@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50908
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752700AbXKAVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 17:35:36 -0400
In-Reply-To: <4729EAFF.9050606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 01 Nov 2007 08:04:31 -0700

> David Miller wrote:
> > The hardware has stripped the VLAN header completely and has not
> > provided it to us at all.
> >   
> Do the NICs not save the QoS bits in the VLAN header anywhere that we could
> use to reconstitute the header?

You get the 16-bit VLAN tag.
