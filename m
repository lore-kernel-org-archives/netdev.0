From: Yisen Zhuang <Yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 04/10] net: hns: add attribute reset-field-offset
 for dsaf node
Date: Sat, 23 Apr 2016 09:41:34 +0800
Message-ID: <571AD2CE.4020905@huawei.com>
References: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1461309619-167621-5-git-send-email-Yisen.Zhuang@huawei.com>
 <20160422204418.GA19071@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160422204418.GA19071@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

Thanks for your suggestion. I will put DT bindings in separate patches,
and modify related dts file in next version.

Thanks,

Yisen

=E5=9C=A8 2016/4/23 4:44, Rob Herring =E5=86=99=E9=81=93:
> On Fri, Apr 22, 2016 at 03:20:13PM +0800, Yisen Zhuang wrote:
>> Add the subctrl reset offset for dsaf, this property is used to rese=
t
>> xge/ge ports for different dsaf. If this attribute is not present,
>> default value 0 will be used.
>>
>> Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>> Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> ---
>>  .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  2 ++
>=20
> Please put DT bindings in separate patches and don't modify the same=20
> binding in a series of patches. You are describing h/w and the h/w is=
=20
> not changing.
>=20
>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  8 +++++
>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  1 +
>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 40 +++++++++++=
++++-------
>>  4 files changed, 39 insertions(+), 12 deletions(-)
>=20
> .
>=20

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
