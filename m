From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v3 09/15] net: dsa: Add support for switch EEPROM access
Date: Thu, 30 Oct 2014 19:53:17 -0700
Message-ID: <5452F99D.5080201@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net> <1414604707-22407-10-git-send-email-linux@roeck-us.net> <20141030211131.GB32139@lunn.ch> <20141030223951.GA19489@roeck-us.net> <20141031010039.GA29492@roeck-us.net> <20141031024044.GA4082@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141031024044.GA4082@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2014 07:40 PM, Andrew Lunn wrote:
>> As suspected, ethtool will attempt to read a zero-length eeprom.
>>
>> The following patch should solve the problem. Not sure if it is worth it,
>> though, since this will change behavior for existing drivers.
>
> Yes, it changes behaviour, but it does make it more consistent.
>
> Probably it should be up to core network people to decide if this is
> the write fix or leave it as is.
>

s/write/right/.

The patch shows up in the netdev patchwork. David marked it as RFC,
so we'll see where it goes.

Thanks,
Guenter
