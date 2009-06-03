From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/1] e1000e: Expose MDI-X status via
	ethtool change
Date: Wed, 03 Jun 2009 18:34:22 +0100
Message-ID: <1244050462.3191.14.camel@achroite>
References: <1243353768.3188.2.camel@achroite>
	 <20090527231542.GA19664@clala-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:34096 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753082AbZFCRe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 13:34:26 -0400
In-Reply-To: <20090527231542.GA19664@clala-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-05-27 at 16:15 -0700, Chaitanya Lala wrote:
[...]
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 380b042..b553bdb 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -30,7 +30,8 @@ struct ethtool_cmd {
>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
>  	__u16	speed_hi;
> -	__u16	reserved2;
> +	__u8	is_mdix;

Since this is specific to Ethernet over=EF=BB=BF twisted-pair cable, co=
uld you
please rename this to "eth_tp_mdix".

> +	__u8	reserved2;
>  	__u32	lp_advertising;	/* Features the link partner advertises */
>  	__u32	reserved[2];
>  };
> @@ -632,6 +633,11 @@ struct ethtool_ops {
>  #define AUTONEG_DISABLE		0x00
>  #define AUTONEG_ENABLE		0x01
> =20
> +/* Mode MDI or MDI-X */
> +#define MDI_INVALID 0x00
> +#define MDI         0x01
> +#define MDI_X       0x02
[...]

Similarly, please add the prefix "ETH_TP_" to these.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

