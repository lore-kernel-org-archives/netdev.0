From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH v2 03/20] net: pcnet: slight optimization of addr compare
Date: Tue, 24 Dec 2013 21:47:30 +0800
Message-ID: <52B99072.5070809@gmail.com>
References: <52B96FA7.10201@huawei.com> <1387888739.2259.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Don Fry <pcnet32@frontier.com>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387888739.2259.7.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2013/12/24 20:38, Joe Perches =E5=86=99=E9=81=93:
> On Tue, 2013-12-24 at 19:27 +0800, Ding Tianhong wrote:
>> Use possibly more efficient ether_addr_equal_unaligned
>> to instead of memcmp.
>=20
> Hi again Ding.
>=20
>> diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethern=
et/amd/pcnet32.c
> []
>> @@ -1668,7 +1668,7 @@ pcnet32_probe1(unsigned long ioaddr, int share=
d, struct pci_dev *pdev)
> []
>> -	if (memcmp(promaddr, dev->dev_addr, ETH_ALEN) ||
>> +	if (!ether_addr_equal(promaddr, dev->dev_addr) ||
>=20
> Can you please make sure the commit message matches the
> code changes?
>=20
> This uses ether_addr_equal not ether_addr_equal_unaligned.
>=20
> Thanks for the work.
>=20

Oh=EF=BC=8C no,  maybe I was dizzy by these patches,  I should be more =
careful,
sorry about that, I will resend this one.

Regards
Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
