From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 20/20] net: caif: slight optimization of
 addr compare
Date: Sat, 28 Dec 2013 09:04:31 -0800
Message-ID: <1388250271.24123.4.camel@joe-AO722>
References: <52BE6D50.9000308@huawei.com>
	 <1388213953.24123.2.camel@joe-AO722> <52BEE7F0.1070506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BEE7F0.1070506@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-12-28 at 23:02 +0800, Ding Tianhong wrote:
> =E4=BA=8E 2013/12/28 14:59, Joe Perches =E5=86=99=E9=81=93:
> > On Sat, 2013-12-28 at 14:18 +0800, Ding Tianhong wrote:
> >> Use possibly more efficient ether_addr_equal
> >> to instead of memcmp.
> >=20
> > This may be a distinction without difference, but
> > is a CAIF seghead also an ethernet address?
> >=20
> NO=EF=BC=8Cthis is a coincidence, the CAIF seghead is 6 bytes too,
> So from a logical point of view, maybe a new function with
> suitable name will be more reasonable here, but the name of
> ether_addr_equal is not correctly here.:)

So please remove this one from the series.
