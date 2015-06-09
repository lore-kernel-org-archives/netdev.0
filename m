From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 2/3] VRF driver and needed infrastructure
Date: Tue, 09 Jun 2015 11:19:47 +0200
Message-ID: <5576AFB3.8060607@6wind.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com> <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, dsahern@gmail.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38156 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbbFIJTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 05:19:50 -0400
Received: by wibdq8 with SMTP id dq8so9561869wib.1
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 02:19:49 -0700 (PDT)
In-Reply-To: <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/06/2015 20:35, Shrijeet Mukherjee a =C3=A9crit :
> From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
[snip]
> --- /dev/null
> +++ b/drivers/net/vrf.c
[snip]
> +
> +static struct rtnl_link_ops vrf_link_ops __read_mostly =3D {
> +	.kind		=3D DRV_NAME,
> +	.priv_size      =3D sizeof(struct net_vrf),
> +	.policy         =3D vrf_nl_policy,
> +	.newlink        =3D vrf_newlink,
> +	.dellink        =3D vrf_dellink,
> +	.setup		=3D vrf_setup,
> +	.validate	=3D vrf_validate,
> +	.maxtype        =3D IFLA_VRF_MAX,
> +};
It would be good to also have a .fill_info callback.
