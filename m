From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: Re: [PATCH v2] net: phy: leds: Add support for "link" trigger
Date: Wed, 1 Nov 2017 13:33:45 +0100
Message-ID: <fb6da2f4-38a7-a116-1910-51795ebb53da@maciej.szmigiero.name>
References: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
 <20171101121611.GD12680@lunn.ch>
 <b789b023-2e7b-1f5b-59a6-9676db74e850@maciej.szmigiero.name>
 <20171101123102.GF12680@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps-vb.mhejs.net ([37.28.154.113]:47586 "EHLO vps-vb.mhejs.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932196AbdKAMdr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 08:33:47 -0400
In-Reply-To: <20171101123102.GF12680@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 01.11.2017 13:31, Andrew Lunn wrote:
>> Yes, I did it the same way as the existing code did for phy->phy_led_triggers
>> for reasons of both consistency and also to be on the safe side because
>> maybe there is some non-obvious reason why it has to be freed
>> explicitly (?).
>  
> Hi Maciej
> 
> Occasionally, there is a need to call devm_kfree(). But i don't see
> anything here why it is needed. So i would drop your devm_kfree(), and
> if you feel like it, add an additional patch removing the existing
> one.

OK, will do as you suggest.

> Thanks
> 	Andrew
> 

Thanks,
Maciej
