From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Move temperature sensor code
 to mv88e6xxx.c
Date: Sat, 25 Jul 2015 12:29:59 -0700
Message-ID: <55B3E3B7.5060600@roeck-us.net>
References: <1437842548-7233-1-git-send-email-linux@roeck-us.net> <20150725184652.GB604@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37500 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbbGYTaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 15:30:01 -0400
In-Reply-To: <20150725184652.GB604@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2015 11:46 AM, Andrew Lunn wrote:
> On Sat, Jul 25, 2015 at 09:42:28AM -0700, Guenter Roeck wrote:
>> Move the temperature sensing code for mv88e6352 and mv88e6320 families
>> into mv88e6xxx.c to simplify adding support for additional chips.
>>
>> With this change, mv88e6xxx_6320_family() no longer needs to be
>> a global function and is made static.
>>
>> Cc: Andrew Lunn <andrew@lunn.ch>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
> Acked-by: Andrew Lunn <andrew@lunn.ch>
>
> Thanks for doing this Guenter
>
My pleasure. Thanks a lot for the review!

Guenter
