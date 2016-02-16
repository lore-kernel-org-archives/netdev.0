From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob V2
Date: Tue, 16 Feb 2016 17:58:50 +0100
Message-ID: <20160216165850.GF29482@lunn.ch>
References: <56BFA87D.1010609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: John Holland <jotihojr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47524 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193AbcBPQ6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 11:58:54 -0500
Content-Disposition: inline
In-Reply-To: <56BFA87D.1010609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 13, 2016 at 11:04:45PM +0100, John Holland wrote:
> Hello,
> 
> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an
> OTP and has no externel EEPROM interface [1]. The following allows
> the driver to pickup the MAC address from a device tree blob when
> CONFIG_OF has been enabled.
> 
> [1] http://www.intel.com/content/www/us/en/embedded/products/networking/i211-ethernet-controller-datasheet.html
> 
> Changes V2
> - Restrict searching for compatible devices to current pci device.
> 
> Signed-off-by: John Holland <jotihojr@gmail.com>

Hi John

Thanks for fixing multiple device support.

Please could you add documentation in
Documentation/devicetree/bindings/net. I know these are standard
properties, but it is somewhat unusual to attach them to a PCI node,
so having an example would be good.

   Thanks
	Andrew
