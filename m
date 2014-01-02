From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH RESEND net-next 1/7] bonding: use ether_addr_equal_unaligned
 for bond addr compare
Date: Thu, 2 Jan 2014 17:00:29 +0800
Message-ID: <52C52AAD.8040603@huawei.com>
References: <52C4BD16.5010702@huawei.com> <alpine.DEB.2.02.1401020839000.2182@localhost6.localdomain6> <52C52180.2030707@huawei.com> <alpine.DEB.2.02.1401020937490.2182@localhost6.localdomain6>
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
In-Reply-To: <alpine.DEB.2.02.1401020937490.2182@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/1/2 16:38, Julia Lawall wrote:
> On Thu, 2 Jan 2014, Ding Tianhong wrote:
>=20
>> On 2014/1/2 15:39, Julia Lawall wrote:
>>> Are the casts needed
>>
>>
>> Yes, otherwise the warming will report:
>>
>> /net-next/drivers/net/bonding/bond_3ad.c:427: warning: passing argum=
ent 1 of =E2=80=98ether_addr_equal_64bits=E2=80=99 from incompatible po=
inter type
>=20
> Is it necessary for this driver to use a different type from everyone=
=20
> else?
>=20
> julia
>=20
Did you mean the MAC_ADDRESS_EQUAL is excess?
I did not remove it because the codes no need to be changed more and it=
 looks that didn't take any negative effect.

Regards
Ding
