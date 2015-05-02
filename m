From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/3] net: dsa: introduce module_switch_driver macro
Date: Sat, 2 May 2015 14:47:23 -0400 (EDT)
Message-ID: <671088801.177214.1430592443529.JavaMail.zimbra@savoirfairelinux.com>
References: <1430518155-29565-1-git-send-email-vivien.didelot@savoirfairelinux.com> <55440D7D.4060504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	kernel <kernel@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55440D7D.4060504@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

>> This commit introduces a new module_switch_driver macro, similar to
>> module_platform_driver and such, to reduce boilerplate when declaring
>> DSA switch drivers.
>>
>> In order to use the module_driver macro, register_switch_driver needed
>> to be changed to return an int instead of void, so make it return 0.
>
> Do we get much benefit from having this change, the diffstat looks
> pretty neutral, ultimately register_switch_driver() might be gone (see:
> http://www.spinics.net/lists/netdev/msg326900.html) and mv88e6xxx cannot
> be converted to it due to how it is designed. This is not a strong
> objection though, the changes look fine to me.

Indeed, I initially introduce the macro for that purpose, I have an RFC ready
to remove the mv88e6xxx module and expose its functions, since it'd better be a
library instead of a driver.

I'll attach it here as a reply to give an idea of what it looks like and 
get feedback from you.

Thanks,
-v
