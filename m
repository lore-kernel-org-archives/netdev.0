From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port speeds/duplex
Date: Mon, 15 Jun 2015 10:32:50 -0700
Message-ID: <557F0C42.1040007@gmail.com>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch> <1434129537-15252-3-git-send-email-andrew@lunn.ch> <557B2181.9090900@gmail.com> <557B2525.7080401@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>, Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33953 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283AbbFOReA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 13:34:00 -0400
Received: by pacgb13 with SMTP id gb13so39505803pac.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 10:34:00 -0700 (PDT)
In-Reply-To: <557B2525.7080401@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/15 11:29, Guenter Roeck wrote:
[snip]

static int dsa_switch_setup_one(struct dsa_switch *ds, struct
>>> device *parent)
>>>   {
>>>       struct dsa_switch_driver *drv = ds->drv;
>>> @@ -204,6 +234,7 @@ static int dsa_switch_setup_one(struct dsa_switch
>>> *ds, struct device *parent)
>>>               }
>>>               dst->cpu_switch = index;
>>>               dst->cpu_port = i;
>>> +            ds->cpu_port_mask |= 1 << i;
>>
>> Same question as Guenter here, I assume this is because you plan on
>> having multiple CPU ports connected to the switch and this makes it
>> easier to deal with, is that right?
>>
> 
> If so, should that be done in a separate patch set ?

I think it would be clearer that way, yes.
-- 
Florian
