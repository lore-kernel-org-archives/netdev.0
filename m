From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 4/4] net: dsa: lan9303: MDIO access phy registers
 directly
Date: Fri, 28 Jul 2017 21:44:49 +0200
Message-ID: <a8ff8b7b-5aff-f25b-5ad3-944fcc867e40@egil-hjelmeland.no>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-5-privat@egil-hjelmeland.no>
 <87fudglget.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <50d2d34c-c1a5-7f0a-90f1-44b1be1775b7@egil-hjelmeland.no>
 <87fudgqz4w.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <1250382a-1c17-8e82-8c5c-fe14786c84db@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1250382a-1c17-8e82-8c5c-fe14786c84db@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Den 28. juli 2017 19:05, skrev Florian Fainelli:
> On 07/28/2017 09:55 AM, Vivien Didelot wrote:
>> Hi Egil,
>>
>> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
>>
>>>>> +const struct lan9303_phy_ops lan9303_indirect_phy_ops = {
>>>>> +	.phy_read = lan9303_indirect_phy_read,
>>>>> +	.phy_write = lan9303_indirect_phy_write,
>>>>> +};
>>>>> +EXPORT_SYMBOL(lan9303_indirect_phy_ops);
>>>>
>>>> Isn't EXPORT_SYMBOL_GPL prefered over EXPORT_SYMBOL?
>>>
>>> I have no opinion. I just used the same variant as the other EXPORTS
>>> in the file.
>>
>> If there is no concern from others about this, LGTM too:
> 
> Since the kernel module license is GPL, EXPORT_SYMBOL_GPL() would seem
> to be appropriate, which can be done as a subsequent patch.
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
I have no idea how these legalities work. But for the record,
I give consent to change to EXPORT_SYMBOL_GPL at any time.

Egil Hjelmeland
