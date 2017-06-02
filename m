From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] net: phy: marvell: make two functions static
Date: Fri, 2 Jun 2017 15:04:09 +0100
Message-ID: <c09480fc-481f-dfab-576b-1427e89e12ae@canonical.com>
References: <20170602111424.31287-1-colin.king@canonical.com>
 <20170602140014.GK12261@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170602140014.GK12261@lunn.ch>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/06/17 15:00, Andrew Lunn wrote:
> On Fri, Jun 02, 2017 at 12:14:24PM +0100, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> functions m88e1510_get_temp_critical and m88e1510_get_temp_alarm can be
>> made static as they not need to be in global scope.
>>
>> Cleans up sparse warnings:
>>  "symbol 'm88e1510_get_temp_alarm' was not declared. Should it be static?"
>>  "symbol 'm88e1510_get_temp_critical' was not declared. Should it be 
>>   static?"
> 
> Hi Colin
> 
> What about m88e1510_get_temp_alarm()? That should also have a static.

Ah, good point, I somehow missed that one. I'll send a V2

Colin
> 
> Thanks
>      Andrew
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

