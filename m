From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] powerpc/44x: Add more changes for APM821XX EMAC
 driver
Date: Wed, 29 Feb 2012 13:25:13 -0500 (EST)
Message-ID: <20120229.132513.1607879808995168004.davem@davemloft.net>
References: <1329466058-15969-1-git-send-email-dhdang@apm.com>
	<CA+5PVA5hciQSvfkodX-oP_kUZueiTp=0+t8X_0iHQ+ehU0ecOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dhdang@apm.com, benh@kernel.crashing.org, paulus@samba.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jwboyer@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+5PVA5hciQSvfkodX-oP_kUZueiTp=0+t8X_0iHQ+ehU0ecOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Josh Boyer <jwboyer@gmail.com>
Date: Wed, 29 Feb 2012 08:43:46 -0500

> On Fri, Feb 17, 2012 at 3:07 AM, Duc Dang <dhdang@apm.com> wrote:
>> This patch includes:
>>
>> =A0Configure EMAC PHY clock source (clock from PHY or internal clock=
).
>>
>> =A0Do not advertise PHY half duplex capability as APM821XX EMAC does=
 not
>> support half duplex mode.
>>
>> =A0Add changes to support configuring jumbo frame for APM821XX EMAC.
>>
>> Signed-off-by: Duc Dang <dhdang@apm.com>
>=20
> This should have been sent to netdev.  CC'ing them now.
>=20
> Ben and David, I can take this change through the 4xx tree if it look=
s OK to
> both of you.  The pre-requisite DTS patch will go through my tree, so=
 it might
> make sense to keep them together.

Well the patch has coding style problems, for one:

>> +			dev->features |=3D (EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE
>> +					| EMAC_FTR_APM821XX_NO_HALF_DUPLEX
>> +					| EMAC_FTR_460EX_PHY_CLK_FIX);

Should be:

>> +			dev->features |=3D (EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE |
>> +					  EMAC_FTR_APM821XX_NO_HALF_DUPLEX |
>> +					  EMAC_FTR_460EX_PHY_CLK_FIX);

And this:

>> +		dev->phy_feat_exc =3D (SUPPORTED_1000baseT_Half
>> +					| SUPPORTED_100baseT_Half
>> +					| SUPPORTED_10baseT_Half);

Should be:

>> +		dev->phy_feat_exc =3D (SUPPORTED_1000baseT_Half |
>> +				     SUPPORTED_100baseT_Half |
>> +				     SUPPORTED_10baseT_Half);
