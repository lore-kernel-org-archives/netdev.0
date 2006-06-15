From: Faidon Liambotis <faidon@cube.gr>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Thu, 15 Jun 2006 08:15:10 +0300
Message-ID: <4490ECDE.2030600@cube.gr>
References: <20060610175010.GA4617@divinity>	 <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com>	 <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity>	 <20060612152434.GA14851@tuxdriver.com> <1150346713.26487.24.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5-static.acn.gr ([213.5.41.24]:8072 "EHLO
	mail5-static.acn.gr") by vger.kernel.org with ESMTP id S932443AbWFOGFA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 02:05:00 -0400
Received: from mailslb.acn.gr (unknown [172.31.10.109])
	by mail5-static.acn.gr (Postfix) with ESMTP id 302A84B3FF4
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 08:14:44 +0300 (EEST)
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <1150346713.26487.24.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Pavel Roskin wrote:
> The patch in question was never submitted to the orinoco mailing list.
> I believe any such changes should be discussed by people using the
> driver and participating in its development.  It's not some minor change
> or API update.
I'm sorry for not submitting/CCing this to the orinoco mailing list, I
should have.

> I'm ready to consider disabling some ID's conditionally, primarily for
> systems that cannot use udev.  But it's far from the top of my TODO
> list.  And I'm not sure it would actually help users of desktop
> distributions.
Well, that would be very nice, thanks!
But do you think that it will be enough? I mean, orinoco_{pci,plx,tdm}
exist only to support Prism2 chipsets.
HostAP a rather big and complete driver for Prism2/2.5/3.0 chipsets;
we're going to have another one based on the dscape stack too.
Do you think that there's a point on having the orinoco driver
supporting this chipset any more?
I don't mean to disrespect your work -- orinoco has served us for quite
a few years, but HostAP seems like a better alternative for these cards.

Please don't get offended by this -- I'm sure you've spent quite some
time on the particular code.

Regarding the disabling of IDs, I could prepare a patch for orinoco_cs
that would disable Prism2 support via a configuration option. Would that
be helpful/acceptable?

Best regards,
Faidon
