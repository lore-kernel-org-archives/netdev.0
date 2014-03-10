From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Mon, 10 Mar 2014 14:25:31 +0000
Message-ID: <20140310142531.1fde5797@alan.etchedpixels.co.uk>
References: <531CF864.9040406@gmail.com>
	<20140309.203001.1318893833441564547.davem@davemloft.net>
	<531D094C.1090205@gmail.com>
	<20140309.204101.47552917508273123.davem@davemloft.net>
	<531D0D0D.4050703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rob@landley.net,
	andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <531D0D0D.4050703@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Mar 2014 01:53:33 +0100
Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> wrote:

> On 03/10/2014 01:41 AM, David Miller wrote:
> > From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> > Date: Mon, 10 Mar 2014 01:37:32 +0100
> >
> >> The mechanism is manual, no automatic way to determine it.
> >
> > We recognize BIOS and ACPI bugs and work around them, by looking at
> > version information and whatnot, so you really can't convince me that
> > something similar can't be done here perhaps in the platform code.
> 
> Hmm, if the is a way to determine the version of that particual u-boot
> I'd be happy to exploit that information.

If there isn't a way for a kernel to determine the U-boot version then
maybe that should get fixed instead. That also solves your problem
because if you can't find the uboot version you know its too old.

Alan
