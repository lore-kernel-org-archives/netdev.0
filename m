From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Fri, 20 Feb 2015 16:39:23 -0800
Message-ID: <54E7D3BB.9040708@roeck-us.net>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com> <54E76EFA.1050209@cumulusnetworks.com> <54E7876A.3060303@gmail.com> <FFEDCF9956066D4D97C463CC178C7F69F22E02@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Viswanath Bandaru <vbandaru@broadcom.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:54249 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbbBUAji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 19:39:38 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YOy6b-001wht-At
	for netdev@vger.kernel.org; Sat, 21 Feb 2015 00:39:37 +0000
In-Reply-To: <FFEDCF9956066D4D97C463CC178C7F69F22E02@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2015 04:20 PM, Viswanath Bandaru wrote:
>
> Like everybody said, the ageing is really the switch's property.  If there are two bridges with ports from same switching device, it becomes tricky to configure ageing time on the switch.  ( I think this is what you may be referring to be saying it needs more thought).
>
There is only so much we can do. One thing we can not do is to change
the existing switch hardware. Maybe we can ask switch vendors to consider
adding the ability to provide aging time per bridge group or per port,
but even if vendors agree to do that, it won't happen quickly, and it
won't fix existing chips.

Asking the switch to set its aging time to min(aging for all ports)
is better than to keep the aging time at the default of 5 minutes
for all ports, no matter what.

Guenter
