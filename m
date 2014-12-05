From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
 flag for switch device offloads
Date: Fri, 5 Dec 2014 11:21:02 +0800
Message-ID: <5481249E.7020902@freescale.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<shm@cumulusnetworks.com>, <gospo@cumulusnetworks.com>,
	Jianhua Xie <jianhua.xie@freescale.com>
To: <roopa@cumulusnetworks.com>, <jiri@resnulli.us>,
	<sfeldma@gmail.com>, <jhs@mojatatu.com>, <bcrl@kvack.org>,
	<tgraf@suug.ch>, <john.fastabend@gmail.com>,
	<stephen@networkplumber.org>, <linville@tuxdriver.com>,
	<nhorman@tuxdriver.com>, <nicolas.dichtel@6wind.com>,
	<vyasevic@redhat.com>, <f.fainelli@gmail.com>,
	<buytenh@wantstofly.org>, <aviadr@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0134.outbound.protection.outlook.com ([157.56.111.134]:39968
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932398AbaLEDVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 22:21:09 -0500
In-Reply-To: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=E5=9C=A8 2014=E5=B9=B412=E6=9C=8805=E6=97=A5 10:26, roopa@cumulusnetwo=
rks.com =E5=86=99=E9=81=93:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This is a generic high level feature flag for all switch asic feature=
s today.
>
> switch drivers set this flag on switch ports. Logical devices like
> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>
> I had to use SWITCH in the name to avoid ambiguity with other feature
> flags. But, since i have been harping about not calling it 'switch',
> I am welcome to any suggestions :)
>
> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
> in net_device_flags.
> ---
>   include/linux/netdev_features.h |    2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_f=
eatures.h
> index 8e30685..68db1de 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -66,6 +66,7 @@ enum {
>   	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs=
 */
>   	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware *=
/
>   	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
> +	NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
I am interested in this flag very much, but I am not very clear
how many offload capabilities does this flag imply.  If this flag
belongs to a general flag and can be accepted by all vendors,
I will reuse this flag to introduce another out going data traffics
distribution offload method to bonding driver.

Thanks & B.R.
Jianhua
>  =20
>   	/*
>   	 * Add your fresh new feature above and remember to update
> @@ -124,6 +125,7 @@ enum {
>   #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
>   #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
>   #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
> +#define NETIF_F_HW_SWITCH_OFFLOAD	__NETIF_F(HW_SWITCH_OFFLOAD)
>  =20
>   /* Features valid for ethtool to change */
>   /* =3D all defined minus driver/device-class-related */
