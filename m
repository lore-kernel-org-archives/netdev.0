From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Sat, 11 Jun 2016 17:39:21 +0200
Message-ID: <20160611153921.GP2338@lunn.ch>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
 <20160610.225156.638004322598763463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mario_limonciello@dell.com, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, pali.rohar@gmail.com,
	anthony.wong@canonical.com, gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42234 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbcFKPja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jun 2016 11:39:30 -0400
Content-Disposition: inline
In-Reply-To: <20160610.225156.638004322598763463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 10:51:56PM -0700, David Miller wrote:
> From: Mario Limonciello <mario_limonciello@dell.com>
> Date: Tue,  7 Jun 2016 13:22:37 -0500
> 
> > The RTL8153-AD supports a persistent system specific MAC address.
> > This means a device plugged into two different systems with host side
> > support will show different (but persistent) MAC addresses.
> > 
> > This information for the system's persistent MAC address is burned in when
> > the system HW is built and available under \_SB.AMAC in the DSDT at runtime.
> > 
> > This technology is currently implemented in the Dell TB15 and WD15 Type-C
> > docks.  More information is available here:
> > http://www.dell.com/support/article/us/en/04/SLN301147
> > 
> > Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> > ---
> > Changes from v5:
> >  * Correct return value if hex2bin succesful but invalid ether addr
> 
> Have things calmed down enough now that I can apply this?

Hi David

I think the code has reaching the level of maturity needed for
acceptance. So for the code quality:

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

What is still open is do we want to accept it at all? Do we accept the
concept of putting the same MAC address on multiple interfaces at
hotplug time? Do we trust BIOS vendors to not keep changing DSDT
property name, since it is not standardised?

Do we want this at all should be decided by somebody more senior then
those passing comments on the code.

	Andrew
