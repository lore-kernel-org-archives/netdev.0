From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Thu, 21 Jan 2010 08:44:17 +0100
Message-ID: <4B5805D1.3000803@trash.net>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53679 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab0AUHoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 02:44:24 -0500
In-Reply-To: <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> +/**
> + * enum ifla_caif
> + * When using RT Netlink to create, destroy or configure a CAIF IP interface,
> + * enum ifla_caif is used to specify the configuration attributes.
> + *
> + * @IFLA_CAIF_IPV4_CONNID:  Connection ID for IPv4 PDP Context.
> + *			    The type of attribute is NLA_U32.
> + * @IFLA_CAIF_IPV6_CONNID:  Connection ID for IPv6 PDP Context.
> + *			    The type of attribute is NLA_U32.
> + * @IFLA_CAIF_LOOPBACK:	    If different from zero, device is doing loopback
> + *			    The type of attribute is NLA_U8.
> + */
> +enum ifla_caif {
> +	IFLA_CAIF_IPV4_CONNID,
> +	IFLA_CAIF_IPV6_CONNID,
> +	IFLA_CAIF_LOOPBACK,
> +	__IFLA_CAIF_MAX
> +};
> +#define	IFLA_CAIF_MAX (__IFLA_CAIF_MAX-1)
> +
> +#endif /*IF_CAIF_H_*/

You should add an IFLA_CAIF_UNSPEC at the beginning, some of the
nlattr helpers skip attributes with a value of zero.
