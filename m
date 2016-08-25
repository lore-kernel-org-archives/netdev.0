From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Thu, 25 Aug 2016 10:09:14 -0400
Message-ID: <5d292cc1-5f1f-e0b0-0744-ac16ab4f14d5@redhat.com>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E813F@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="v9vHlmdXgdM0pXStu87M0uuWVPeG6Xvpf"
Cc: "Huwei (Xavier)" <xavier.huwei@huawei.com>,
        oulijun <oulijun@huawei.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A6E813F@lhreml503-mbx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--v9vHlmdXgdM0pXStu87M0uuWVPeG6Xvpf
Content-Type: multipart/mixed; boundary="2PuvtMI5d9N0V6QgDLxGR1g2xVFqH64DD"
From: Doug Ledford <dledford@redhat.com>
To: Salil Mehta <salil.mehta@huawei.com>, David Miller <davem@davemloft.net>
Cc: "Huwei (Xavier)" <xavier.huwei@huawei.com>, oulijun <oulijun@huawei.com>,
 "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
 "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Linuxarm <linuxarm@huawei.com>
Message-ID: <5d292cc1-5f1f-e0b0-0744-ac16ab4f14d5@redhat.com>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E813F@lhreml503-mbx>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A6E813F@lhreml503-mbx>

--2PuvtMI5d9N0V6QgDLxGR1g2xVFqH64DD
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 8/25/2016 8:08 AM, Salil Mehta wrote:
>=20
>=20
>> -----Original Message-----
>> From: Doug Ledford [mailto:dledford@redhat.com]
>> Sent: Thursday, August 25, 2016 12:57 PM
>> To: David Miller; Salil Mehta
>> Cc: Huwei (Xavier); oulijun; Zhuangyuzeng (Yisen);
>> mehta.salil.lnk@gmail.com; linux-rdma@vger.kernel.org;
>> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
>> Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to=

>> the Hisilicon RoCE Driver
>>
>> On 8/25/2016 12:53 AM, David Miller wrote:
>>> From: Salil Mehta <salil.mehta@huawei.com>
>>> Date: Wed, 24 Aug 2016 04:44:48 +0800
>>>
>>>> This patch is meant to add support of ACPI to the Hisilicon RoCE
>> driver.
>>>> Following changes have been made in the driver(s):
>>>>
>>>> Patch 1/2: HNS Ethernet Driver: changes to support ACPI have been
>> done in
>>>>    the RoCE reset function part of the HNS ethernet driver. Earlier
>> it only
>>>>    supported DT/syscon.
>>>>
>>>> Patch 2/2. HNS RoCE driver: changes done in RoCE driver are meant to=

>> detect
>>>>    the type and then either use DT specific or ACPI spcific
>> functions. Where
>>>>    ever possible, this patch tries to make use of "Unified Device
>> Property
>>>>    Interface" APIs to support both DT and ACPI through single
>> interface.
>>>>
>>>> NOTE 1: ACPI changes done in both of the drivers depend upon the
>> ACPI Table
>>>>      (DSDT and IORT tables) changes part of UEFI/BIOS. These changes=

>> are NOT
>>>>      part of this patch-set.
>>>> NOTE 2: Reset function in Patch 1/2 depends upon the reset function
>> added in
>>>>      ACPI tables(basically DSDT table) part of the UEFI/BIOS. Again,=

>> this
>>>>      change is NOT reflected in this patch-set.
>>>
>>> I can't apply this series to my tree because the hns infiniband
>> driver
>>> doesn't exist in it.
>>>
>>
>> No.  This probably needs to go through my tree.  Although with all of
>> the requirements, I'm a bit concerned about those being present
>> elsewhere.
>>
>> --
>> Doug Ledford <dledford@redhat.com>
>>     GPG Key ID: 0E572FDD
> Hello Doug,
> Thanks for your reply. I have just replied to David email as well and d=
id
> not realize your response was already on the way. Sorry for this!
>=20
> I would just like to request, if by any chance, we can expedite the acc=
eptance
> of the below patch (part of patch-set) in the net-next. This might help=
 you as
> well in future when you will actually push the RoCE driver to the linux=
-next.
>=20
> "[PATCH for-next 1/2] net: hns: Add support of ACPI to HNS driver RoCE =
Reset
>  function"
>=20
> Below HNS RoCE reset function patch has already been accepted by Dave M=
iller and
> is part of net-next,
> https://patchwork.kernel.org/patch/9287497/
>=20
> Also, above ACPI support of RoCE Reset patch cleanly applies over the a=
lready
> accepted patch in the link and is not dependent on other accompanying R=
oCE
> driver ACPI changes or even the presence of the Infiniband/RoCE Driver =
in the
> net-next repository.
>=20
> Could you please suggest if this the something which can be considered?=
  =20

I've pulled both of these patches in.  I usually merge late in the merge
window, so it won't be any stretch to wait until the ACPI tree has been
merged before I send Linus my pull request.


--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--2PuvtMI5d9N0V6QgDLxGR1g2xVFqH64DD--

--v9vHlmdXgdM0pXStu87M0uuWVPeG6Xvpf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXvvwKAAoJELgmozMOVy/dAfgP/3JgQeMjZvhiJlGP1FsUFAsH
4OOHWZfthZtuF3zs6ggr0YoqwOE6v8IFX3Hs4ISDms4EUaCKx96w3tARSwpha3+4
Ny9p9Lx34GqlRDnF+CjcZb8Y9FjXjb6Ob3Br4INdgVHeIa3yDed+urlv4TwRleAB
MLI4eYK1SpmiEYbwmW93Z4yO71SHbSKuqvmUNLGVdqWCyaZFpd0NJ6IfjVW8wVxU
UHa24BMecS+QZ9jkMWLfvLkZNGquIVRZawKMeEkh/PPzTfoB8GOT1wgb+z0qYLOw
pWAYUjviGqvdd7UrRrsQCxqqEyYalOC07RCKv2EpzPTOkau21XzDkDx43GBs7pXl
XzxTcJsxlzxtMWwGWm2jx86MSNZmD14yu5GC28293HK+WjD0ywgT+EssH8KRnk/j
QG81GyxSscNP1bRURHdm0pdrtt7z/Zrw/pCYDKRm7j5oNbQjOeNzTafQNX9QegxI
HUH9wirMydwIWdf9e1mmu1WUxu1GbuQlgVA0tVwPfW2ato3aU3GYgSXfqpRGtQmB
1AiOtpjTIveubeRCL7z9Kwv1lmKkW/J88P2RDqYgrBfsICGa6yNxWfUsL1bzzZn4
VVXU1ySCv9vAWCuVPbn2lFbOndH88JVvBtaGmoTACu2u0CJulPWZ7p3bKENMOTkK
ZkKb2qHK02h9U2HD5bp3
=EwAs
-----END PGP SIGNATURE-----

--v9vHlmdXgdM0pXStu87M0uuWVPeG6Xvpf--
