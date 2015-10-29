From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [RFC PATCH v3 1/5] net: dsa: allow switch drivers to cleanup
 their resources
Date: Thu, 29 Oct 2015 15:56:28 +0100
Message-ID: <5632339C.8000302@baylibre.com>
References: <56323104.2030606@baylibre.com> <20151029145052.GU2307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151029145052.GU2307@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2015 03:50 PM, Andrew Lunn wrote:
> On Thu, Oct 29, 2015 at 03:45:24PM +0100, Neil Armstrong wrote:
>> --- a/net/dsa/dsa.c
>> +++ b/net/dsa/dsa.c
>> @@ -459,6 +459,10 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>>  	}
>>
>>  	mdiobus_unregister(ds->slave_mii_bus);
>> +
>> +	/* Leave a chance to the driver to cleanup */
>> +	if (ds->drv->remove)
>> +		ds->drv->remove(ds);
>>  }
> 
> https://lkml.org/lkml/2015/10/28/532 ???
> 
>      Andrew
> 
Well, sorry, I did the change but it got lost when refactoring the ppu stuff.

Neil
