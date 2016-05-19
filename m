From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Thu, 19 May 2016 12:21:38 +0200
Message-ID: <6103030.g2sqFmaRhG@ws-stein>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com> <5f2d9a6d-bcf1-5aa1-7c45-f8cfd723bc3a@phrozen.org> <CABwW5nm9itJUrfP6yNEgQPDcPojKvsPbxv6tdoJ0DFPDY9XrSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: John Crispin <john@phrozen.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, "Mehrtens, Hauke" <hauke.mehrtens@intel.com>
To: Mathias Kresin <openwrt@kresin.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:49789 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbcESKVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 06:21:45 -0400
In-Reply-To: <CABwW5nm9itJUrfP6yNEgQPDcPojKvsPbxv6tdoJ0DFPDY9XrSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 May 2016 12:03:10, Mathias Kresin wrote:
> 2016-05-19 9:03 GMT+02:00 John Crispin <john@phrozen.org>:
> > On 19/05/2016 08:57, Alexander Stein wrote:
> >> Thanks for the link, I wasn't aware of that patch. I like it in general,
> >> but there are some things I'd like to get addressed first:
> >> * vr9_gphy_of_reg_init() writes uncoditionally to led3h and led3l even on
> >> 
> >>   PEf7071 which does not have this register at all
> > 
> > we use this driver mainly on the 11g and 22f version. mathias recently
> > added the led3 handling.
> > 
> > @Mathias, can you have a look at this and fix it inside the lede tree ?
> 
> Well, I haven't added the led3 handling, I've only changed the initial
> value (function) of led3.
> 
> Maybe it's cleaner to not use a default value for the led function and
> completely rely on the device tree bindings. But by adjusting the
> initial values, I had to change only the led function of one board in
> the openwrt xrx200 subtarget instead of touching all dts files.

I think setting default values is good.

> I know that the LTQ Datasheet for the PEF 7071 Version 1.5 mentions
> the led3 control register albeit there is no pin for a forth led. So I
> guess it's safe to write to the led3 register even for the PEF 7071.

Mh, my PEF 7071 User Manual (Version 2.0, 2012-10-17) doesn't mention LED3x 
registers. There is LED3DA and LED3EN in PHY_LED but was removed in 1.6 
manual.
I think, some flag if the PHY supports LED3 and depend on that is just fine.

Best regards,
Alexander
