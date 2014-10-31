From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 09/15] net: dsa: Add support for switch EEPROM access
Date: Thu, 30 Oct 2014 23:43:13 -0400 (EDT)
Message-ID: <20141030.234313.2253116750470358032.davem@davemloft.net>
References: <20141031010039.GA29492@roeck-us.net>
	<20141031024044.GA4082@lunn.ch>
	<5452F99D.5080201@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5452F99D.5080201@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 30 Oct 2014 19:53:17 -0700

> On 10/30/2014 07:40 PM, Andrew Lunn wrote:
>>> As suspected, ethtool will attempt to read a zero-length eeprom.
>>>
>>> The following patch should solve the problem. Not sure if it is worth
>>> it,
>>> though, since this will change behavior for existing drivers.
>>
>> Yes, it changes behaviour, but it does make it more consistent.
>>
>> Probably it should be up to core network people to decide if this is
>> the write fix or leave it as is.
>>
> 
> s/write/right/.
> 
> The patch shows up in the netdev patchwork. David marked it as RFC,
> so we'll see where it goes.

As per your patch, I think we should fix this to not return a zero
length eeprom when the driver doesn't support it.

If dsa behaves outside of the defined behavior of what ethtool
implementations in ethernet drivers do, then it's ok to change it
because it's a bonafide bug fix in my eyes.

So if you submit this formally, I would apply it.

Thanks.
