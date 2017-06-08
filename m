From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Thu, 8 Jun 2017 18:03:31 +0200
Message-ID: <20170608160331.GA20216@lunn.ch>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41729 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750725AbdFHQDh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 12:03:37 -0400
Content-Disposition: inline
In-Reply-To: <20170608092653.25221-8-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 08, 2017 at 11:26:52AM +0200, Antoine Tenart wrote:
> +#define MVMDIO_XSMI_MGNT_REG		0x0
> +#define  MVMDIO_XSMI_READ_VALID		BIT(29)
> +#define  MVMDIO_XSMI_BUSY		BIT(30)
> +#define MVMDIO_XSMI_ADDR_REG		0x8
> +#define  MVMDIO_XSMI_PHYADDR_SHIFT	16
> +#define  MVMDIO_XSMI_DEVADDR_SHIFT	21
> +#define  MVMDIO_XSMI_READ_OPERATION	(0x7 << 26)
> +#define  MVMDIO_XSMI_WRITE_OPERATION	(0x5 << 27)

Hi Antoine

These two operations seem odd. Generally ops have the same shift.

      Andrew
