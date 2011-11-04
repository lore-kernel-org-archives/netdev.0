From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Fri, 04 Nov 2011 23:16:07 +0200
Message-ID: <1320441367.2113.4.camel@Joe-Laptop>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111104172446.GB12913@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Hamish Coleman <hamish@zot.apana.org.au>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54826 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752547Ab1KDVPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 17:15:30 -0400
In-Reply-To: <20111104172446.GB12913@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-04 at 17:24 +0000, Russell King - ARM Linux wrote:
> Okay, this is the only patch I saw (for the SEEQ drivers), but I notice
> that more of the ARM drivers have moved.  The result is not nice.  Or
> even workable.
> 
> While looking for my ether1, ether3 and etherh drivers in Kconfig, I
> enable every option which is presented to me under the new 'ethernet
> drivers' stuff.  I'm offered my ether3 driver under the SEEQ stuff -
> that's fine.  But what about the rest?
[]
> While I realise this is a big change, and bugs like this are likely, it
> would've been nice to be copied on more of the patches which affect
> drivers I maintain.

Hi Russell.

What drivers in drivers/net do you maintain?

I believe this is the list in MAINTAINERS for you:

ARM/EBSA110 MACHINE SUPPORT
F:      drivers/net/ethernet/amd/am79c961a.*
ARM/RISCPC ARCHITECTURE
F:      drivers/net/ethernet/i825xx/ether1*
F:      drivers/net/ethernet/seeq/ether3*

Are there others? If yes, what are they?
