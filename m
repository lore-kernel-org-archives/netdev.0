From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Thu, 12 Mar 2015 01:19:26 +0100
Message-ID: <20150312001926.GB9601@lunn.ch>
References: <20150310190129.GB5636@codeaurora.org>
 <20150310193151.GE10838@lunn.ch>
 <20150310204021.GA2740@codeaurora.org>
 <CAGVrzcZcLgMWuNJ9R_izuBRyyY21=ZJw+2Dk8RfxijGd2fMXNQ@mail.gmail.com>
 <20150311011802.GA10875@codeaurora.org>
 <20150311133057.GA9601@lunn.ch>
 <20150311233738.GA5566@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Jonas Gorski <jogo@openwrt.org>
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58169 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbbCLAWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 20:22:51 -0400
Content-Disposition: inline
In-Reply-To: <20150311233738.GA5566@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Agreed. The switches I'm talking about (QCA8xxx/AR8xxx) don't support
> a mode which would allow them to use all the CPU ports as one logical
> bonding interface.

I had a 60 second look at https://www.codeaurora.org/cgit/quic/qsdk/oss/lklm/qca-ssdk/

It looks like dess, isis, and isisc have some support for trunks, and
the rest do not.

> I know some of these switches don't even support tagging. So I'd be
> surprised if they're all capable of bonding.

So we are going to end up with multiple solutions depending on what
the hardware is capable of.

> I think DSA should probably support both. I think it should allow
> bonding for switches who support it, but it should also allow for port
> based vlan mapped by the user.

So the question is, how do you make the existing concepts in Linux
support this, so configuration is how you expect it to be, without
special cases, oddities, etc.

	Andrew
