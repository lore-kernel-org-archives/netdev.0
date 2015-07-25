From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Move temperature sensor code
 to mv88e6xxx.c
Date: Sat, 25 Jul 2015 12:29:35 -0700
Message-ID: <55B3E39F.20709@roeck-us.net>
References: <1437842548-7233-1-git-send-email-linux@roeck-us.net> <678254299.92854.1437850709856.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37375 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964792AbbGYT3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 15:29:38 -0400
In-Reply-To: <678254299.92854.1437850709856.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2015 11:58 AM, Vivien Didelot wrote:
> On Jul 25, 2015, at 12:42 PM, Guenter Roeck linux@roeck-us.net wrote:
>
>> Move the temperature sensing code for mv88e6352 and mv88e6320 families
>> into mv88e6xxx.c to simplify adding support for additional chips.
>>
>> With this change, mv88e6xxx_6320_family() no longer needs to be
>> a global function and is made static.
>>
>> Cc: Andrew Lunn <andrew@lunn.ch>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
> Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>
> On a Marvell 88E6352.

Thanks a lot for testing!

Guenter
