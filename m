From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH] net: phy: vitesse: add support for VSC8601
Date: Fri, 13 Nov 2015 10:06:19 +0000
Message-ID: <yw1xk2pmkyck.fsf@unicorn.mansr.com>
References: <1447353672-4365-1-git-send-email-mans@mansr.com>
	<5645A48E.9090402@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mason <slash.tmp@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5645A48E.9090402@free.fr> (Mason's message of "Fri, 13 Nov 2015
	09:51:26 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mason <slash.tmp@free.fr> writes:

> On 12/11/2015 19:41, Mans Rullgard wrote:
>
>> +	.phy_id         =3D PHY_ID_VSC8601,
>> +	.name           =3D "Vitesse VSC8601",
>> +	.phy_id_mask    =3D 0x000ffff0,
>> +	.features       =3D PHY_GBIT_FEATURES,
>> +	.flags          =3D PHY_HAS_INTERRUPT,
>> +	.config_init    =3D &genphy_config_init,
>> +	.config_aneg    =3D &genphy_config_aneg,
>> +	.read_status    =3D &genphy_read_status,
>> +	.ack_interrupt  =3D &vsc824x_ack_interrupt,
>> +	.config_intr    =3D &vsc82xx_config_intr,
>
> I expected Documentation/CodingStyle to forbid taking the address
> of functions.

I can't find anything to that effect.  That said, it's not something I
would normally do, but all the other phy_driver entries in that file
look like that.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
