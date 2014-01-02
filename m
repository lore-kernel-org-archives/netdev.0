From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH RESEND net-next 1/7] bonding: use ether_addr_equal_unaligned
 for bond addr compare
Date: Thu, 2 Jan 2014 18:38:33 +0800
Message-ID: <52C541A9.8060002@huawei.com>
References: <52C4BD16.5010702@huawei.com> <alpine.DEB.2.02.1401020839000.2182@localhost6.localdomain6> <52C52180.2030707@huawei.com> <alpine.DEB.2.02.1401020937490.2182@localhost6.localdomain6> <52C52AAD.8040603@huawei.com> <alpine.DEB.2.02.1401021011400.2182@localhost6.localdomain6> <52C53EC6.30902@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C53EC6.30902@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/1/2 18:26, Ding Tianhong wrote:
> On 2014/1/2 17:14, Julia Lawall wrote:
>> On Thu, 2 Jan 2014, Ding Tianhong wrote:
>>
>>> On 2014/1/2 16:38, Julia Lawall wrote:
>>>> On Thu, 2 Jan 2014, Ding Tianhong wrote:
>>>>
>>>>> On 2014/1/2 15:39, Julia Lawall wrote:
>>>>>> Are the casts needed
>>>>>
>>>>>
>>>>> Yes, otherwise the warming will report:
>>>>>
>>>>> /net-next/drivers/net/bonding/bond_3ad.c:427: warning: passing ar=
gument 1 of =E2=80=98ether_addr_equal_64bits=E2=80=99 from incompatible=
 pointer type
>>>>
>>>> Is it necessary for this driver to use a different type from every=
one=20
>>>> else?
>>>>
>>>> julia
>>>>
>>> Did you mean the MAC_ADDRESS_EQUAL is excess?
>>> I did not remove it because the codes no need to be changed more an=
d it looks that didn't take any negative effect.
>>
>> No, I was wondering about the mac_addr type, defined in bond_3ad.h. =
 Other=20
>> code just has the array inlined into the containing structure.
>>
>> julia
>>

I reviewed the struct mac_addr again, and feel that even it looks not c=
omfortable, but
make the lacp struct more meaning for 3ad, what do you think about it, =
I think no need
to revert them to u8.

Regards
Ding

>=20
> Oh, sorry for mismatch.:)
> The code for bond_3ad mode is too old and the use for mac addr is not=
 so comfortable.
>=20
> I think I need to send a patch to fix the unusual mac addr and make i=
t more reasonable.
>=20
> Thanks for your opinion.
>=20
> Regards
> Ding=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
