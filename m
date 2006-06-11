From: Faidon Liambotis <faidon@cube.gr>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Mon, 12 Jun 2006 01:49:54 +0300
Message-ID: <20060611224954.GA2880@divinity>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux7.grserver.gr ([64.34.170.238]:55263 "EHLO
	linux7.grserver.gr") by vger.kernel.org with ESMTP id S1750936AbWFLG2W
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 02:28:22 -0400
To: Dave Jones <davej@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060611224054.GB13139@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 11, 2006 at 06:40:54PM -0400, Dave Jones wrote:
> Ah-ha, I had tested the wrong card.
> I also have a Sitecom card, which matches this ident you remove in your patch..
> 
> PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002), /* Safeway 802.11b, ZCOMAX AirRunner/XI-300 */
> 
<snip>
> 
> So with your patch, this card will become totally useless to me.
I think you should forward this bug to the HostAP maintainer. This
should be either be fixed in the driver or the driver should stop
claiming that it supports this card.

I merely found the duplicate IDs and removed them from Orinoco. I don't
have neither the hardware or the time to test 30+ cards...

Having two drivers supporting the same set of hardware seems pretty
pointless to me. Plus, it confuses hotplugging/automatic detection.

Regards,
Faidon
