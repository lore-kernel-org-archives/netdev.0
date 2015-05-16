From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Allow EEE for all RGMII variants
Date: Fri, 15 May 2015 19:01:40 -0700
Message-ID: <5556A504.4080804@gmail.com>
References: <1431732641-17683-1-git-send-email-f.fainelli@gmail.com> <20150515.212209.277936395883084581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux@roeck-us.net, peppe.cavallaro@st.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34204 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946121AbbEPCBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 22:01:43 -0400
Received: by oiko83 with SMTP id o83so95537047oik.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 19:01:42 -0700 (PDT)
In-Reply-To: <20150515.212209.277936395883084581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/15/15 18:22, David Miller a =C3=A9crit :
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Fri, 15 May 2015 16:30:41 -0700
>=20
>> RGMII interfaces come in multiple flavors: RGMII with transmit or
>> receive internal delay, no delays at all, or delays in both directio=
n.
>>
>> This change extends the initial check for PHY_INTERFACE_MODE_RGMII t=
o
>> cover all of these variants since EEE should be allowed for any of t=
hese
>> modes, since it is a property of the RGMII, hence Gigabit PHY capabi=
lity
>> more than the RGMII electrical interface and its delays.
>>
>> Fixes: a59a4d192166 ("phy: add the EEE support and the way to access=
 to the MMD registers")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>=20
> This is not the first time I've seen this bug.
>=20
> A helper like phydev_is_rgmii() is probably long overdue.

Sounds very reasonable, I will cook something which does that, thanks!

>=20
>> David this change dates back to 3.6, however the comment update will=
 depend on
>> a9f6309585cbefa4a7f08c9017ca482c3222323a ("net: phy: allow phy_init_=
eee() to
>> work with internal PHYs") to be included, which is only 3.18, nobody=
 but me
>> really complained about that so I guess 3.18+ is reasonable.
>=20
> Ok, applied and queued up for -stable, thanks.
>=20


--=20
=46lorian
