From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 3/3] rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD
Date: Thu, 4 Dec 2014 22:16:06 -0800
Message-ID: <CAE4R7bDCcE94WQE50J+suAr9F=OFvQnC73txA+xrC2JxMseYkw@mail.gmail.com>
References: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com>
	<5481259C.3040707@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jianhua Xie <jianhua.xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:42880 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaLEGQI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 01:16:08 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so321113wiw.9
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 22:16:07 -0800 (PST)
In-Reply-To: <5481259C.3040707@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2014 at 7:25 PM, Jianhua Xie <jianhua.xie@freescale.com>=
 wrote:
>
> =E5=9C=A8 2014=E5=B9=B412=E6=9C=8805=E6=97=A5 10:26, roopa@cumulusnet=
works.com =E5=86=99=E9=81=93:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch just sets the feature flag on rocker ports
>> ---
>>   drivers/net/ethernet/rocker/rocker.c |    3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c
>> b/drivers/net/ethernet/rocker/rocker.c
>> index fded127..3fe19b0 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -4003,7 +4003,8 @@ static int rocker_probe_port(struct rocker *ro=
cker,
>> unsigned int port_number)
>>                        NAPI_POLL_WEIGHT);
>>         rocker_carrier_init(rocker_port);
>>   -     dev->features |=3D NETIF_F_HW_VLAN_CTAG_FILTER;
>> +       dev->features |=3D NETIF_F_HW_VLAN_CTAG_FILTER |
>> +                                        NETIF_F_HW_SWITCH_OFFLOAD;
>
> Do you have a plan on enabling/disabling  this flag dynamically by et=
htool?

Might get it for free if we recycle NETIF_F_HW_L2FW_DOFFLOAD;
NETIF_F_HW_L2FW_DOFFLOAD seems to be supported by ethtool already.

>
> Thanks & B.R
> Jianhua
>
>>         err =3D register_netdev(dev);
>>         if (err) {
>
>
