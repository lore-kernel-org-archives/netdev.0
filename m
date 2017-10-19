From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Thu, 19 Oct 2017 13:32:24 +0200
Message-ID: <da663b5a-5459-2e99-79a2-3fdc3daef70b@pengutronix.de>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <4c5b5e9f-44dc-0bf5-5131-b3caf54f390e@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="SnRGdHpU7Qi16MD9A0mn14mI1rpgeKa4R"
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>
To: Sekhar Nori <nsekhar@ti.com>,
        Franklin S Cooper Jr <fcooper@ti.com>,
        =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, wg@grandegger.com,
        socketcan@hartkopp.net, quentin.schulz@free-electrons.com,
        edumazet@google.com, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4c5b5e9f-44dc-0bf5-5131-b3caf54f390e@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SnRGdHpU7Qi16MD9A0mn14mI1rpgeKa4R
Content-Type: multipart/mixed; boundary="QFLIQNjbEae27756682336GC9TDxO9emE";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Sekhar Nori <nsekhar@ti.com>, Franklin S Cooper Jr <fcooper@ti.com>,
 =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
 "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, wg@grandegger.com,
 socketcan@hartkopp.net, quentin.schulz@free-electrons.com,
 edumazet@google.com, linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Wenyou Yang <wenyou.yang@atmel.com>, Dong Aisheng <b29396@freescale.com>,
 "Quadros, Roger" <rogerq@ti.com>
Message-ID: <da663b5a-5459-2e99-79a2-3fdc3daef70b@pengutronix.de>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <4c5b5e9f-44dc-0bf5-5131-b3caf54f390e@ti.com>
In-Reply-To: <4c5b5e9f-44dc-0bf5-5131-b3caf54f390e@ti.com>

--QFLIQNjbEae27756682336GC9TDxO9emE
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: quoted-printable

On 10/19/2017 01:09 PM, Sekhar Nori wrote:
> On Thursday 19 October 2017 02:43 PM, Marc Kleine-Budde wrote:
>> On 10/19/2017 07:07 AM, Sekhar Nori wrote:
>>>>>> Sounds reasonable. What's the status of this series?
>>>>>
>>>>> I have had some offline discussions with Franklin on this, and I am=
 not
>>>>> fully convinced that DT is the way to go here (although I don't hav=
e the
>>>>> agreement with Franklin there).
>>>>
>>>> Probably the fundamental area where we disagree is what "default" SS=
P
>>>> value should be used. Based on a short (< 1 ft) point to point test
>>>> using a SSP of 50% worked fine. However, I'm not convinced that this=

>>>> default value of 50% will work in a more "traditional" CAN bus at hi=
gher
>>>> speeds. Nor am I convinced that a SSP of 50% will work on every MCAN=

>>>> board in even the simplest test cases.
>>>>
>>>> I believe that this default SSP should be a DT property that allows =
any
>>>> board to determine what default value works best in general.
>>>
>>> With that, I think, we are taking DT from describing board/hardware
>>> characteristics to providing default values that software should use.=

>>
>> If the default value is board specific and cannot be calculated in
>> general or from other values present in the DT, then it's from my poin=
t
>> of view describing the hardware.
>>
>>> In any case, if Marc and/or Wolfgang are okay with it, binding
>>> documentation for such a property should be sent to DT maintainers fo=
r
>>> review.
>>>
>>>>>
>>>>> There are two components in configuring the secondary sample point.=
 It
>>>>> is the transceiver loopback delay and an offset (example half of th=
e bit
>>>>> time in data phase).
>>>>>
>>>>> While the transceiver loopback delay is pretty board dependent (and=
 thus
>>>>> amenable to DT encoding), I am not quite sure the offset can be
>>>>> configured in DT because its not really board dependent.
>>>>>
>>>>> Unfortunately, offset calculation does not seem to be an exact scie=
nce.
>>>>> There are recommendations ranging from using 50% of bit time to mak=
ing
>>>>> it same as the sample point configured. This means users who need t=
o
>>>>> change the SSP due to offset variations need to change  their DT ev=
en
>>>>> without anything changing on their board.
>>>>>
>>>>> Since we have a netlink socket interface to configure sample point,=
 I
>>>>> wonder if that should be extended to configure SSP too (or at least=
 the
>>>>> offset part of SSP)?
>>>>
>>>> Sekhar is right that ideally the user should be able to set the SSP =
at
>>>> runtime. However, my issue is that based on my experience CAN users
>>>> expect the driver to just work the majority of times. For unique use=

>>>> cases where the driver calculated values don't work then the user sh=
ould
>>>> be able to override it. This should only be done for a very small
>>>> percentage of CAN users. Unless you allow DT to provide a default SS=
P
>>>> many users of MCAN may find that the default SSP doesn't work and mu=
st
>>>> always use runtime overrides to get anything to work. I don't think =
that
>>>> is a good user experience which is why I don't like the idea.
>>>
>>> Fair enough. But not quite sure if CAN users expect CAN-FD to "just
>>> work" without doing any bittiming related setup.
>>
>> From my point of view I'd rather buy a board from a HW vendor where
>> CAN-FD works, rather than a board where I have to tweak the bit-timing=

>> for a simple CAN-FD test setup.
>>
>> As far as I see for the m_can driver it's a single tuple: "bitrate > 2=
=2E5
>> MBit/s -> 50%". Do we need an array of tuples in general?

Do we need more than one tuple here?

>> If good default values are transceiver and board specific, they can go=

>> into the DT. We need a generic (this means driver agnostic) binding fo=
r
>> this. If this table needs to be tweaked for special purpose, then we c=
an
>> add a netlink interface for this as well.
>>
>> Comments?
>=20
> I dont know how a good default (other than 50% as the starting point)
> can be arrived at without doing any actual measurements on the actual
> network. Since we do know that the value has to be tweaked, agree that
> netlink interface has to be provided.
>=20
> I wonder whether even if a DT binding for default is provided, everyone=

> will end up setting it to 50% (since there is no way for them to predic=
t
> any better). In effect, I am suggesting using a hardcoded value of 50%
> instead of introducing a binding without a clear need for it.

Ok, if the value is network and not board specific it doesn't belong
into the DT.

> Note that I am only talking about there "offset" part of SSP here. The
> transceiver loopback delay is calculated automatically by Bosch's MCAN
> IP. But if there are other IPs which don't do that, then yes, that
> should be a DT property IMO.

Ok, but let's wait for such an IP core to show up here :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--QFLIQNjbEae27756682336GC9TDxO9emE--

--SnRGdHpU7Qi16MD9A0mn14mI1rpgeKa4R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlnojUgACgkQHv7KIOw4
HPbrxAgAuGdTVblez2KYNluTkyhRl9Aix1/6yFlKRHvG86KHIfpCFI+fmmjqg1yJ
oh1gEihgna3b9alDCEkbwR7KgMLwZJ1m8JDqzdWXhHf0zAtFmq+7Ho/ul/CssR0i
DJML/Atziju9PKWFA8UPcKHRWDtnsNnwnHsgw7YmmLK69hM87p0uKZw3T3IBcDXD
K0d7mb7Afcri9oZ7OMwiHvSzETLYXsahO7XvT8kk9/VYchLlXMFNxIWuEQMOmOSz
nJ7Vo+SOvEgsCfAcpoKJFnB1KNxovgcT9c0LErDxxcU69uOwoklja5ZSxXcpScvp
suten09yVHjVHHfFUWd8IxifFjzMKQ==
=sWPy
-----END PGP SIGNATURE-----

--SnRGdHpU7Qi16MD9A0mn14mI1rpgeKa4R--
