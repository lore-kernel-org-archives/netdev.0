From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect
 ops
Date: Tue, 18 Jul 2017 10:46:36 -0700 (PDT)
Message-ID: <20170718.104636.315406311682846961.davem@davemloft.net>
References: <20170717210405.GC11719@lunn.ch>
        <20170717.141048.999243831453421230.davem@davemloft.net>
        <e65f425d-d6c2-f1c3-ea92-c2a0878add44@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e65f425d-d6c2-f1c3-ea92-c2a0878add44@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 18 Jul 2017 09:01:01 -0700

> On 07/17/2017 02:10 PM, David Miller wrote:
>> From: Andrew Lunn <andrew@lunn.ch>
>> Date: Mon, 17 Jul 2017 23:04:05 +0200
>> 
>>> On Mon, Jul 17, 2017 at 01:45:49PM -0700, David Miller wrote:
>>>> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>>>> Date: Mon, 17 Jul 2017 15:32:52 -0400
>>>>
>>>>> Hi Andrew,
>>>>>
>>>>> Andrew Lunn <andrew@lunn.ch> writes:
>>>>>
>>>>>> I never liked this. I think it is architecturally wrong for the switch
>>>>>> to be poking around in the PHY. It should ask the PHY driver. This is
>>>>>> especially true for external PHYs which might not be a Marvell PHY.
>>>>>
>>>>> I share the same concern. However this patch is just isolating the
>>>>> existing code so that we get rid of the last caps and flags and stop
>>>>> writing (without reading them first) arbitrary registers.
>>>>>
>>>>> Once this portion is moved to the PHY driver, one can remove it from
>>>>> mv88e6xxx.
>>>>
>>>> Seems a reasonable plan of action.
>>>>
>>>> Andrew, do you agree?
>>>
>>> Hi David
>>>
>>> I just fear it will not get fixed, just put into a corner to
>>> fester. Having to fix it properly before these patches are merged
>>> provides some incentive.
>> 
>> If Vivien doesn't make good on his promises to do so, tell me and
>> I will revert all of these changes.
>> 
>> Ok?
> 
> This seems to be completely unfair to Vivien, there is nothing wrong
> with his patch series per-se other than he was unfortunate enough he
> highlighted something that needs fixing. This was not a serious enough
> problem before and it cannot possibly be one now either with just a code
> move.
> 
> On a general note, we cannot have whoever was the last one to touch a
> piece of code that makes us see that this or that said piece of code is
> less than ideal be selected as the random victim for doing that cleanup,
> this just does not work. I know this is standard practice in Linux and
> other open source software (been there before with the USB maintainers),
> but this creates only one thing: making you want to runaway and scream
> lalalalala.
> 
> So let's be pragmatic and maintain a public TODO list for this driver
> that people can pick items to fix/cleanup/change that have been
> identified as candidates for patches.

However, in this particular case, this issue was brought to Vivien's
attention multiple times in the past.

And I think the direct PHY poking issue is much more important than
these seemingly endless reorganizations of the driver that Vivien is
doing.

So I personally share Andrew's serious frustration that we are doing
constant reorgs but not addressing directly the specific issues that
one has been made clearly aware of.

Thanks.
