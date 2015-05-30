From: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Subject: Re: [PATCH 3/7] net: dsa: ar8xxx: add regmap support
Date: Sun, 31 May 2015 01:38:55 +0300
Message-ID: <CAHNKnsROztQuCvd6vSfBtXS-0aQY6KjiZTRfA=0zW6-sS5iqHw@mail.gmail.com>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
 <1432863742-18427-4-git-send-email-mathieu@codeaurora.org>
 <5567C7B6.5060905@gmail.com> <20150529022329.GH11260@lunn.ch>
 <5567D0BA.5020409@gmail.com> <20150529024425.GI11260@lunn.ch>
 <005b01d09a36$0b77daa0$22678fe0$@codeaurora.org> <20150529175913.GB19580@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mathieu Olivari <mathieu@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	David Miller <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>, gang.chen.5i5j@gmail.com,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	leitec@staticky.com, fabf@skynet.be, pavel.nakonechny@skitlab.ru,
	Joe Perches <joe@perches.com>, sfeldma@gmail.com,
	Felix Fietkau <nbd@openwrt.org>,
	Gabor Juhos <juhosg@openwrt.org>, devicetree@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:34223 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbE3WjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 18:39:17 -0400
In-Reply-To: <20150529175913.GB19580@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-05-29 20:59 GMT+03:00 Andrew Lunn <andrew@lunn.ch>:
> On Fri, May 29, 2015 at 10:36:49AM -0700, Mathieu Olivari wrote:
>> Alternatively, we could have something similar to what happens for the phy
>> in the wireless subsystems. Wireless PHYs are not registered as net_device
>> but they can still be listed, queried or configured through netlink.
>
> It is a reasonable idea, but you retrieve most of the useful
> information using ethtool. That, as far as i know, operates on
> net_devices, not phys.
>
May be it's time to rework Ethernet cards handling to decouple
"Network interfaces" from "Ethernet ports"?

-- 
Sergey
