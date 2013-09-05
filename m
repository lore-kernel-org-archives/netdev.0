From: yves@cheny.fr
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 =?UTF-8?Q?adjust=5Flink=28=29=20works?=
Date: Thu, 05 Sep 2013 08:23:12 +0200
Message-ID: <ca521df880b08225cb34214e3ef0fc2c@cheny.fr>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130904163245.GI20552@1wt.eu>
 <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
 <20130905051223.GB26000@1wt.eu>
 <CACzLR4uCQhGzgABV2nMG45EQBNsrW8=j5X7x-=eTSUmSvthLxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Peter Sanford <psanford@nearbuy.io>,
	Ryan Press <ryan@presslab.us>,
	Simon Guinot <simon.guinot@sequanux.org>, vdonnefort@lacie.com,
	stable@vger.kernel.org
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CACzLR4uCQhGzgABV2nMG45EQBNsrW8=j5X7x-=eTSUmSvthLxg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Willy,
i would be interested too !

thx
Yves

Le 2013-09-05 07:22, Ethan Tuttle a =C3=A9crit=C2=A0:
> Understood.  Ultimately, I'll use this board as a router, and stable
> mac addresses would be better than random.  So I would be interested
> to try your atag -> device tree patches.  Have they been posted
> somewhere I can find them?
>=20
> Thanks Willy.
>=20
> Ethan
>=20
> On Wed, Sep 4, 2013 at 10:12 PM, Willy Tarreau <w@1wt.eu> wrote:
>> Hi,
>>=20
>> On Wed, Sep 04, 2013 at 09:14:23PM -0700, Ethan Tuttle wrote:
>>> Just booted with the patch on my Mirabox.  Both interfaces work!
>>> Thank you Thomas.
>>>=20
>>> One remaining issue is that the interface which uBoot didn't=20
>>> configure
>>> is still getting a random mac address:
>>>=20
>>> mvneta d0070000.ethernet eth0: Using hardware mac address=20
>>> f0:ad:4e:01:dc:97
>>> mvneta d0074000.ethernet eth1: Using random mac address=20
>>> d2:35:dd:c8:99:48
>>>=20
>>> This is on 3.11 plus Thomas' patch, which includes the previous fix=
=20
>>> to
>>> "read MAC address from hardware when available".  Perhaps that fix
>>> isn't working with the phylib?
>>=20
>> No this is unrelated. The MAC isn't configured by the boot loader wh=
en
>> the NIC is not used. U-boot only passes it as a non-standard ATAG. I
>> have some patches to reinject the non-standard atags into the device
>> tree if you absolutely need this, but they're not suited for mainlin=
e
>> inclusion from what I understood last time I proposed them (they use
>> a marvell-specific atag header).
>>=20
>> Regards,
>> Willy
>>=20
