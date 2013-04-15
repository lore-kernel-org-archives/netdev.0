From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 0/5 v2] mv643xx_eth: device tree bindings
Date: Mon, 15 Apr 2013 12:00:11 +0200
Message-ID: <20130415120011.61e4b44c@skate>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <20130411165303.GI28693@titan.lakedaemon.net>
 <20130413172126.6cca0809@skate>
 <20130413190037.GY28693@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>, davem@davemloft.net,
	moinejf@free.fr, andrew@lunn.ch, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
	grant.likely@secretlab.ca, jogo@openwrt.org,
	buytenh@wantstofly.org, jm@lentin.co.uk,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:47363 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab3DOKAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 06:00:21 -0400
In-Reply-To: <20130413190037.GY28693@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jason Cooper,

On Sat, 13 Apr 2013 15:00:37 -0400, Jason Cooper wrote:

> > So let's continue the cleanup work, conversion to DT, usage of
> > drivers in drivers/, improvement of pinmux to support
> > orion5x/mv78xx0, and do the move per-platform, once they are ready.
> > 
> > What do you think?
> 
> I agree completely.  I was simply restating the longview goal of the
> work we are doing (above and beyond adding armadaXP/370).  I probably
> should have given a time reference for "This will lead to..." :)

Ok. I definitely agree with the long-term goal.

> Also, I have a feeling that not all legacy boards will get converted
> over.  If there is no interest or no way to test, certains boards may
> get deprecated.

I think for many of them, we can do a 'blind' conversion to DT, and ask
the users who have posted patches or even submitted support for those
boards to test the DT. But I don't think we should move things into
mach-mvebu if there are still legacy non-DT Kirkwood platforms
supported in mach-kirkwood. So either we convert them to the DT, or we
remove the support for them if no-one is really interested. But I
believe in most cases, converting them to DT should be quite easy.

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
