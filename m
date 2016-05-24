From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Tue, 24 May 2016 18:30:47 +0200
Message-ID: <20160524163047.GF8897@lunn.ch>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com>
 <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
 <20160503153659.GA29815@lunn.ch>
 <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
 <20160509120634.GQ7972@lunn.ch>
 <CAOLz05o5SELBH6LovChQrFXQWXOZANhrYrTNcuktM_nKnp10VQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Amr Bekhit <amrbekhit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48981 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756003AbcEXQau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2016 12:30:50 -0400
Content-Disposition: inline
In-Reply-To: <CAOLz05o5SELBH6LovChQrFXQWXOZANhrYrTNcuktM_nKnp10VQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2016 at 05:09:35PM +0100, Amr Bekhit wrote:
> Hi Andrew,
> 
> > How about adding a printk() in genphy_read_status().
> 
> Would you be able to point me to some more information about these
> status bits, please?

You can get the datasheet from here:

http://www.davicom.com.tw/userfile/24247/DM9162_DM9162I-12-MCO-DS-F01_08062014.pdf

I would start by looking at the BMCR register. The
genphy_read_status() function should get called about once per second,
so that is an O.K. place to add debug prints, and there is example
code for reading MII_BMCR.

     Andrew
