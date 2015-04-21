From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 0/3] Enable connecting DSA-based switch to the USB
 RMII interface.
Date: Tue, 21 Apr 2015 19:30:12 +0200
Message-ID: <20150421173012.GK32294@lunn.ch>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
 <20150421124737.GD32294@lunn.ch>
 <55368667.5030105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kaisrlik <kaisrja1@fel.cvut.cz>, sojkam1@fel.cvut.cz,
	tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55368667.5030105@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> My goal in reworking this weird DSA device/driver model is that you
> could just register your switch devices as an enhanced
> phy_driver/spi_driver/pci_driver etc..., such that libphy-ready drivers
> could just take advantage of that when they scan/detect their MDIO buses
> and find a switch. We are not quite there yet, but some help could be
> welcome, here are the WIP patches (tested with platform_driver only so far):

We are hijacking another thread, but...

I don't understand you here. Who calls dsa_switch_register()?

I know of a board coming soon which has three switch chips on
it. There is one MDIO device in the Soc, but there is an external MDIO
multiplexor controlled via gpio lines, such that each switch has its
own MDIO bus. The DT binding does not support this currently, but the
underlying data structures do.

How do you envisage dsa_switch_register() to work in such a setup?

Thanks
    Andrew
