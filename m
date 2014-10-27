From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2 09/15] net: dsa: Add support for switch EEPROM access
Date: Mon, 27 Oct 2014 06:22:35 -0700
Message-ID: <544E471B.8080507@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net> <1414342365-27191-10-git-send-email-linux@roeck-us.net> <20141027024121.GA16998@lunn.ch> <544DC264.9020600@roeck-us.net> <20141027085048.GC4748@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141027085048.GC4748@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2014 01:50 AM, Richard Cochran wrote:
> On Sun, Oct 26, 2014 at 08:56:20PM -0700, Guenter Roeck wrote:
>>
>> Also, it seems that you request two separate properties, one for presence
>> and another for length. Is that correct ? Again, I thought that would not
>> provide any value since presence is indicated by length != 0 in the ethtool
>> callback function. No problem, though, I'll be happy to create two separate
>> properties and platform data variables if you think that would be better.
>
> The fewer properties, the better.
>

Right now I have:

Optional properties:
- eeprom-length         : Set to the length of an EEPROM connected to the
                           switch. Must be set if the switch can not detect
                           the presence and/or size of a connected EEPROM,
                           otherwise optional.

and I think Andrew is asking for the following:

Optional properties:
- eeprom-present	: Boolean property indicating that an EEPROM is present.
			  Must be set if an EEPROM is present.
- eeprom-length         : Set to the length of an EEPROM connected to the
                           switch. Must be set if the switch can not detect
                           the size of a connected EEPROM, otherwise optional.

Platform data semantics would be the same.

I can go either way, but I would like to get some kind of agreement before I jump
into writing the code.

Thanks,
Guenter
