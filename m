From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v3 2/2] net: ethernet: nb8800: handle all RGMII definitions
Date: Mon, 07 Nov 2016 11:51:27 +0000
Message-ID: <yw1xk2cfik3k.fsf@unicorn.mansr.com>
References: <581CD1AF.6030300@laposte.net> <581CD210.5060206@laposte.net>
        <yw1xoa1uhylu.fsf@unicorn.mansr.com> <58205103.4090208@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58205103.4090208@laposte.net> (Sebastian Frias's message of
        "Mon, 7 Nov 2016 11:01:39 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Frias <sf84@laposte.net> writes:

> Hi Måns,
>
> On 11/05/2016 01:58 PM, Måns Rullgård wrote:
>>>  	if (gigabit) {
>>> -		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
>>> +		if (phy_interface_is_rgmii(phydev))
>>>  			mac_mode |= RGMII_MODE;
>>>
>>>  		mac_mode |= GMAC_MODE;
>> 
>> As I said before, this part can/should be applied separately, although
>> personally I probably wouldn't have bothered adding a single-use variable.
>
> It was for consistency with other functions that use 'phydev', but I don't
> mind making the changes.
>
> Just to be clear, when you say "can/should be applied separately", do you
> mean that this patch should not be part of a series, and that I should split
> the series into separate patches?

I meant that this change should be made regardless of the others and can
be done separately if desired.

-- 
Måns Rullgård
