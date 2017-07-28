From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 4/4] net: dsa: lan9303: MDIO access phy registers
 directly
Date: Fri, 28 Jul 2017 18:24:07 +0200
Message-ID: <50d2d34c-c1a5-7f0a-90f1-44b1be1775b7@egil-hjelmeland.no>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-5-privat@egil-hjelmeland.no>
 <87fudglget.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fudglget.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Den 28. juli 2017 17:39, skrev Vivien Didelot:
> Hi Egil,
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>> +const struct lan9303_phy_ops lan9303_indirect_phy_ops = {
>> +	.phy_read = lan9303_indirect_phy_read,
>> +	.phy_write = lan9303_indirect_phy_write,
>> +};
>> +EXPORT_SYMBOL(lan9303_indirect_phy_ops);
> 
> Isn't EXPORT_SYMBOL_GPL prefered over EXPORT_SYMBOL?
> 
> 
> Thanks,
> 
>          Vivien
> 

I have no opinion. I just used the same variant as the other EXPORTS in
the file.

Egil
