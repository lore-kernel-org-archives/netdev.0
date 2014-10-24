From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Fri, 24 Oct 2014 01:03:06 -0400 (EDT)
Message-ID: <20141024.010306.1939269479587208896.davem@davemloft.net>
References: <1414037002-25528-7-git-send-email-linux@roeck-us.net>
	<CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
	<54488CE1.2000106@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, andrew@lunn.ch,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54488CE1.2000106@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 22 Oct 2014 22:06:41 -0700

> On 10/22/2014 09:37 PM, Florian Fainelli wrote:
>> 2014-10-22 21:03 GMT-07:00 Guenter Roeck <linux@roeck-us.net>:
>>> Some Marvell switches provide chip temperature data.
>>> Add support for reporting it to the dsa infrastructure.
>>>
>>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>>> ---
>> [snip]
>>
>>> +/* hwmon support
>>> ************************************************************/
>>> +
>>> +#if defined(CONFIG_HWMON) || (defined(MODULE) &&
>>> defined(CONFIG_HWMON_MODULE))
>>
>> IS_ENABLED(CONFIG_HWMON)?
>>
> 
> Hi Florian,
> 
> unfortunately, that won't work; I had it initially and got a nice
> error message
> from Fengguang's build test bot.

Then the Kconfig dependencies are broken.

Fix Kconfig to only allow legal combinations.
