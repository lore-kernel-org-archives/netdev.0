From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Simplify
 lan9303_xxx_packet_processing() usage
Date: Mon, 31 Jul 2017 17:08:12 +0200
Message-ID: <6bc09c91-14b7-f28d-4f1f-f243f12b2940@egil-hjelmeland.no>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no>
 <20170731113355.4284-3-privat@egil-hjelmeland.no>
 <87379c4sfe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <3207fcff-8318-9b17-c546-026ab1a1511b@egil-hjelmeland.no>
 <87o9s01xb3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <3eafb133-2b39-a1c5-6c01-917799fb6320@egil-hjelmeland.no>
 <87shhc6471.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87shhc6471.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31. juli 2017 17:01, Vivien Didelot wrote:
> Hi Egil,
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>> Would doing
>>
>> -	chip->ds = dsa_switch_alloc(chip->dev, DSA_MAX_PORTS);
>> +	chip->ds = dsa_switch_alloc(chip->dev, LAN9303_NUM_PORTS);
>>
>> at the same time be good, or breaking the scope of the patch?
> 
> It is indeed out of scope. You may want to add a first commit "net: dsa:
> lan9303: introduce LAN9303_NUM_PORTS" for instance.
> 

In a later series I assume? Or is allowed to add patches to a series
under review?


> 
> Thanks,
> 
>          Vivien
> 

Egil
