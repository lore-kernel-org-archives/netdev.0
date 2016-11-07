From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH v3 2/2] net: ethernet: nb8800: handle all RGMII
 definitions
Date: Mon, 7 Nov 2016 11:01:39 +0100
Message-ID: <58205103.4090208@laposte.net>
References: <581CD1AF.6030300@laposte.net> <581CD210.5060206@laposte.net>
 <yw1xoa1uhylu.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xoa1uhylu.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Måns,

On 11/05/2016 01:58 PM, Måns Rullgård wrote:
>>  	if (gigabit) {
>> -		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
>> +		if (phy_interface_is_rgmii(phydev))
>>  			mac_mode |= RGMII_MODE;
>>
>>  		mac_mode |= GMAC_MODE;
> 
> As I said before, this part can/should be applied separately, although
> personally I probably wouldn't have bothered adding a single-use variable.

It was for consistency with other functions that use 'phydev', but I don't
mind making the changes.

Just to be clear, when you say "can/should be applied separately", do you
mean that this patch should not be part of a series, and that I should split
the series into separate patches?

Best regards,

Sebastian
