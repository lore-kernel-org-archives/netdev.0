From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 1/3] net: dsa: mv88e6xxx: add debugfs interface for
 VTU
Date: Tue, 7 Jul 2015 12:19:29 -0400 (EDT)
Message-ID: <1021310176.218025.1436285969810.JavaMail.zimbra@savoirfairelinux.com>
References: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1436148893-14379-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20150707020818.GB5540@lunn.ch> <1165322565.210276.1436284349938.JavaMail.zimbra@savoirfairelinux.com> <20150707160744.GA13230@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:50711 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbbGGQTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 12:19:33 -0400
In-Reply-To: <20150707160744.GA13230@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter, Andrew,

----- On Jul 7, 2015, at 12:07 PM, Andrew Lunn andrew@lunn.ch wrote:

>> Indeed, I intentionally kept it as is, since the 88E6352 datasheet is not
>> really clear about this. I see that the register 0x09 (called
>> GLOBAL_VTU_DATA_8_11 in mv88e6xxx.h) only contains VID priority related bits in
>> 15:12, in my case. As bits 11:0 are reserved, I suspect that the offsets of
>> Member TagP7, Member TagP8 and Member TagP9 are respectively 0, 4 and 8 for
>> you. Can you confirm? If so, I'll make that generic with these values.
> 
> Yes, the pattern continues for up to 11 ports, if you look at the DSDT
> sources from Marvell. The mv88e6131.c driver has one device, the 6095,
> with 11 ports.

Thanks for the details. I make the change and send a v4 asap.

Best,
-v
