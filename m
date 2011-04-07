From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/5] be2net: add rxhash support
Date: Thu, 07 Apr 2011 07:05:25 +0200
Message-ID: <1302152725.2701.60.camel@edumazet-laptop>
References: <20110407040743.GA4183@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44227 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab1DGFFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 01:05:31 -0400
Received: by wwa36 with SMTP id 36so2586433wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 22:05:29 -0700 (PDT)
In-Reply-To: <20110407040743.GA4183@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 23:07 -0500, Ajit Khaparde a =C3=A9cri=
t :
> Add rxhash support,
> Based on initial work by Eric Dumazet.
>=20
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
> ---
>  drivers/net/benet/be.h         |    5 +++++
>  drivers/net/benet/be_ethtool.c |   13 +++++++++++++
>  drivers/net/benet/be_main.c    |   17 ++++++++++++-----
>  3 files changed, 30 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
> index 0899d91..8941b98 100644
> --- a/drivers/net/benet/be.h
> +++ b/drivers/net/benet/be.h
> @@ -485,6 +485,11 @@ static inline void be_vf_eth_addr_generate(struc=
t be_adapter *adapter, u8 *mac)
>  	memcpy(mac, adapter->netdev->dev_addr, 3);
>  }
> =20
> +static inline bool be_multi_rxq(struct be_adapter *adapter)

static inline bool be_multi_rxq(const struct be_adapter *adapter)


> +{
> +	return (adapter->num_rx_qs > 1);

	return adapter->num_rx_qs > 1;

> +}
> +

Other parts seems fine, thanks !


