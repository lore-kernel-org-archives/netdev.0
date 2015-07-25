From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Move temperature sensor code
 to mv88e6xxx.c
Date: Sat, 25 Jul 2015 14:58:29 -0400 (EDT)
Message-ID: <678254299.92854.1437850709856.JavaMail.zimbra@savoirfairelinux.com>
References: <1437842548-7233-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:55324 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbbGYS6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 14:58:32 -0400
In-Reply-To: <1437842548-7233-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jul 25, 2015, at 12:42 PM, Guenter Roeck linux@roeck-us.net wrote:

> Move the temperature sensing code for mv88e6352 and mv88e6320 families
> into mv88e6xxx.c to simplify adding support for additional chips.
> 
> With this change, mv88e6xxx_6320_family() no longer needs to be
> a global function and is made static.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

On a Marvell 88E6352.
Thanks,
-v
