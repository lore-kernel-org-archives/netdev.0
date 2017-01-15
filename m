From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next v3 00/10] net: dsa: Support for pdata in dsa2
Date: Sun, 15 Jan 2017 12:08:31 +0100
Message-ID: <20170115110831.GH26374@kroah.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170114214713.28109-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2017 at 01:47:03PM -0800, Florian Fainelli wrote:
> Hi all,
> 
> This is not exactly new, and was sent before, although back then, I did not
> have an user of the pre-declared MDIO board information, but now we do. Note
> that I have additional changes queued up to have b53 register platform data for
> MIPS bcm47xx and bcm63xx.
> 
> Yes I know that we should have the Orion platforms eventually be converted to
> Device Tree, but until that happens, I don't want any remaining users of the
> old "dsa" platform device (hence the previous DTS submissions for ARM/mvebu)
> and, there will be platforms out there that most likely won't never see DT
> coming their way (BCM47xx is almost 100% sure, BCM63xx maybe not in a distant
> future).
> 
> We would probably want the whole series to be merged via David Miller's tree
> to simplify things.
> 
> Greg, can you Ack/Nack patch 5 since it touched the core LDD?

I've NAKed them for now, you need to describe what you are trying to do
here, as it doesn't make any sense to me at the moment.

thanks,

greg k-h
