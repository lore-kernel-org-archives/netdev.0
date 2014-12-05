From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: [PATCH 3/3] rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD
Date: Fri, 5 Dec 2014 11:25:16 +0800
Message-ID: <5481259C.3040707@freescale.com>
References: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<shm@cumulusnetworks.com>, <gospo@cumulusnetworks.com>,
	jianhua Xie <jianhua.xie@freescale.com>
To: <roopa@cumulusnetworks.com>, <jiri@resnulli.us>,
	<sfeldma@gmail.com>, <jhs@mojatatu.com>, <bcrl@kvack.org>,
	<tgraf@suug.ch>, <john.fastabend@gmail.com>,
	<stephen@networkplumber.org>, <linville@tuxdriver.com>,
	<nhorman@tuxdriver.com>, <nicolas.dichtel@6wind.com>,
	<vyasevic@redhat.com>, <f.fainelli@gmail.com>,
	<buytenh@wantstofly.org>, <aviadr@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0115.outbound.protection.outlook.com ([157.56.111.115]:41235
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932098AbaLEDZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 22:25:27 -0500
In-Reply-To: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=E5=9C=A8 2014=E5=B9=B412=E6=9C=8805=E6=97=A5 10:26, roopa@cumulusnetwo=
rks.com =E5=86=99=E9=81=93:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch just sets the feature flag on rocker ports
> ---
>   drivers/net/ethernet/rocker/rocker.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ether=
net/rocker/rocker.c
> index fded127..3fe19b0 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -4003,7 +4003,8 @@ static int rocker_probe_port(struct rocker *roc=
ker, unsigned int port_number)
>   		       NAPI_POLL_WEIGHT);
>   	rocker_carrier_init(rocker_port);
>  =20
> -	dev->features |=3D NETIF_F_HW_VLAN_CTAG_FILTER;
> +	dev->features |=3D NETIF_F_HW_VLAN_CTAG_FILTER |
> +					 NETIF_F_HW_SWITCH_OFFLOAD;
Do you have a plan on enabling/disabling  this flag dynamically by etht=
ool?

Thanks & B.R
Jianhua
>  =20
>   	err =3D register_netdev(dev);
>   	if (err) {
