From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Mon, 9 May 2016 14:06:34 +0200
Message-ID: <20160509120634.GQ7972@lunn.ch>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com>
 <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
 <20160503153659.GA29815@lunn.ch>
 <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Amr Bekhit <amrbekhit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59691 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198AbcEIMGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 08:06:36 -0400
Content-Disposition: inline
In-Reply-To: <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amr

Please don't top post.

> Based on the information I pasted below, it appears that
> autonegotiation is working - the device detects that there is a link
> partner connected and ethtool reports back the various link modes that
> can be used.

This suggests the PHY to cable is O.K. and your problem is between the
MAC and the PHY.

> I'm not sure about the status bits - I couldn't find out how I would
> check them.

How about adding a printk() in genphy_read_status().

    Andrew
