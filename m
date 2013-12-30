From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 20/20] net: caif: slight optimization of addr
 compare
Date: Mon, 30 Dec 2013 10:14:15 +0800
Message-ID: <52C0D6F7.2020301@huawei.com>
References: <52BE6D50.9000308@huawei.com>	 <1388213953.24123.2.camel@joe-AO722> <52BEE7F0.1070506@gmail.com> <1388250271.24123.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Ding Tianhong <dthxman@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388250271.24123.4.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/12/29 1:04, Joe Perches wrote:
> On Sat, 2013-12-28 at 23:02 +0800, Ding Tianhong wrote:
>> =E4=BA=8E 2013/12/28 14:59, Joe Perches =E5=86=99=E9=81=93:
>>> On Sat, 2013-12-28 at 14:18 +0800, Ding Tianhong wrote:
>>>> Use possibly more efficient ether_addr_equal
>>>> to instead of memcmp.
>>>
>>> This may be a distinction without difference, but
>>> is a CAIF seghead also an ethernet address?
>>>
>> NO=EF=BC=8Cthis is a coincidence, the CAIF seghead is 6 bytes too,
>> So from a logical point of view, maybe a new function with
>> suitable name will be more reasonable here, but the name of
>> ether_addr_equal is not correctly here.:)
>=20
> So please remove this one from the series.
>=20
>=20

Yes, Ok!

Regards
Ding
>=20
>=20
