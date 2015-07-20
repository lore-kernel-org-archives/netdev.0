From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 0/5] switchdev: avoid duplicate packet
 forwarding
Date: Mon, 20 Jul 2015 20:08:55 +0200
Message-ID: <20150720180855.GH14842@lunn.ch>
References: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
 <55AD3687.9010002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, simon.horman@netronome.com,
	nicolas.dichtel@6wind.com, vivien.didelot@savoirfairelinux.com,
	linux@roeck-us.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44432 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183AbbGTSPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 14:15:31 -0400
Content-Disposition: inline
In-Reply-To: <55AD3687.9010002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This looks good to me, and it looks like this is also relevant for
> DSA-driven switches, however I am not exactly clear on how we could
> potentially use this on such switches.
> 
> For Broadcom tags, there is a reason code forwarded along with the tag
> making it to the CPU, and the "mirror" bit sounds like something that
> should dictate whether we should be setting the fwd_mark or not.
> 
> What does it look like on Marvell switches?

Hi Florian

There are some bits indicating some status information. But these are
more to do with BDPU, IGMP/MLD and ARP.

I've not yet had time to dig into the details here. I suspect the D in
DSA is going to make this very interesting.

    Andrew
