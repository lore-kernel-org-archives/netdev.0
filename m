From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v2 net-next 1/2] net: dsa: lan9303: Move tag setup to new
 lan9303_setup_tagging
Date: Wed, 11 Oct 2017 10:16:30 +0200
Message-ID: <20f8c457-0f61-641e-a12a-7c0bcf2fba21@egil-hjelmeland.no>
References: <20171010124953.386-1-privat@egil-hjelmeland.no>
 <20171010124953.386-2-privat@egil-hjelmeland.no>
 <9235D6609DB808459E95D78E17F2E43D40B48C3D@CHN-SV-EXMX02.mchp-main.com>
 <2d03fb99-fd1c-9a0b-3274-eda605c3eb2d@egil-hjelmeland.no>
 <9235D6609DB808459E95D78E17F2E43D40B48CC6@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Woojung.Huh@microchip.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B48CC6@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10. okt. 2017 17:51, Woojung.Huh@microchip.com wrote:
>>> Specific reason to use val then using
>> LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0
>>> like previous line?
>>>
>> Specific reason was to please a reviewer that did not like my
>> indenting in first version. I did not agree with him, but since
>> nobody else spoke up, I changed the code.
> Got it. Missed previous patch/comment.
> 
>>>> @@ -644,6 +648,10 @@ static int lan9303_setup(struct dsa_switch *ds)
>>>>    		return -EINVAL;
>>>>    	}
>>>>
>>>> +	ret = lan9303_setup_tagging(chip);
>>>> +	if (ret)
>>>> +		dev_err(chip->dev, "failed to setup port tagging %d\n", ret);
>>>> +
>>> Still move on when error happens?
>>>
>> Good question. I just followed the pattern from the original function,
>> which was not made by me. Actually I did once reflect on whether this
>> was the correct way. Perhaps it could be argued that it is better to
>> allow the device to come up, so the problem can be investigated?
> Maybe depends on severity of setting?
> BTW, lan9303_setup() still returns ZERO at the end?
I did quick survey of the _setup functions of the other dsa drivers.
Some return on error, some ignore errors.
If you think so, I can make a v3 series that return on error. Otherwise
I leave it as it is.

> 
> Thanks.
> Woojung
> 

Thank you for polite review.

Egil
