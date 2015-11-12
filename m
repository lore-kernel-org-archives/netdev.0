From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Thu, 12 Nov 2015 18:08:01 +0100
Message-ID: <20151112170801.GG20177@lunn.ch>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60232 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbbKLRIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 12:08:04 -0500
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2015 at 04:02:18PM +0000, Premkumar Jonnala wrote:
> Packet forwarding to/from bond interfaces is done in software.
> 
> This patch enables certain platforms to bridge traffic to/from
> bond interfaces in hardware.  Notifications are sent out when 
> the "active" slave set for a bond interface is updated in 
> software.  Platforms use the notifications to program the 
> hardware accordingly.  The changes have been verified to work 
> with configured and 802.3ad bond interfaces.

Hi Premkumar

Nice to see this. Do you also have patches for a switch using these
notification? Are you targeting Starfighter 2?

Thanks
	Andrew
