From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Microsemi VSC 8531/41 PHY Driver
Date: Fri, 29 Jul 2016 10:04:02 +0200
Message-ID: <20160729080402.GA13798@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
 <20160726124347.GD11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53498 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917AbcG2IEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 04:04:06 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2016 at 06:44:37AM +0000, Raju Lakkaraju wrote:
> Hello Andrew,
> 
> Thank you for given valuable comments.
> Please see the my responses inline.
> 
> Thanks,
> Raju
> 
> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch] 
> Sent: Tuesday, July 26, 2016 6:14 PM
> To: Raju Lakkaraju
> Cc: netdev@vger.kernel.org; f.fainelli@gmail.com; Allan Nielsen
> Subject: Re: Microsemi VSC 8531/41 PHY Driver
> 
> EXTERNAL EMAIL
> 
> 
> > +/* RGMII Rx Clock delay value change with board lay-out */ static u8 
> > +rgmii_rx_clk_delay = RGMII_RX_CLK_DELAY_1_1_NS;
> 
> Doesn't this stop you from having a board with two PHYs with different layouts? You should be getting this value from the device tree.
> 
> Raju: As of now, RGMII Rx clock delay value should be 1.1 nsec as optimized/recommended value. 
> We tested on Beaglebone Black with VSC 8531 PHY.
> We would like to provide new function to configure correct/require value based on PHY layouts 
> alone with other RGMII configuration parameters as part of our next implementation.

Hi Raju

Please can you use standard email quoting, just like everybody else does.

       Andrew
