From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2 09/15] net: dsa: Add support for switch EEPROM access
Date: Mon, 27 Oct 2014 08:42:10 -0700
Message-ID: <20141027154210.GA7677@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
 <1414342365-27191-10-git-send-email-linux@roeck-us.net>
 <20141027024121.GA16998@lunn.ch>
 <544DC264.9020600@roeck-us.net>
 <20141027135917.GA12627@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141027135917.GA12627@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 27, 2014 at 02:59:17PM +0100, Andrew Lunn wrote:
> > So lets take a step back: For the Marvell chips, I have to provide both length
> > and presence in devicetree or platform data. Presence seemed to be implied by
> > length, so I used only a single property and variable to indicate both.
> 
> Hi Guenter
> 
> What i was thinking, is that you don't need length in device tree. The
> datasheet specifies how big the EEPROM needs to be.
> 
> However, i read the datasheet for the 6060, the only public datasheet
> from Marvell. It does not work as i expected. Rather than being a
> fixed list of register values, it is a variable length list of
> command/value pairs.
> 
> In this situation, yes, you do need the length in DT.
> 
Correct. The 6352 supports "2K bit (93C56) or 4K bit (93C66) 4-wire EEPROM
devices as well as 1K bit (24C01), 2K bit (24C02) or 4K bit (24C04) 2-wire
EEPROM", so the length can be anything from 128 to 512 bytes.

> I had a quick look at some other switch chips. e.g. the RTL8100. It
> has a fixed layout of its EEPROM, consisting of 0x80 bytes. In this
> case, the switch driver could be hard coded with 0x80, and all DT
> needs to indicate is if the EEPROM is present or not.
> 
> So, what you have proposed will work. It is maybe not optimal in the
> case of a well defined in the datasheet fixed size EEPROM, but it
> still works.
> 
> Acked-by: Andrew Lunn <andrew@lunn.ch>
> 
Thanks!

Guenter
