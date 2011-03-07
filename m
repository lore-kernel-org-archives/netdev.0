From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: enhance the documentation for
 rx_handler.
Date: Mon, 7 Mar 2011 08:36:07 -0800
Message-ID: <20110307083607.3299ed0c@nehalam>
References: <4D725BD9.6000706@gmail.com>
	<1299441608-25482-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, kaber@trash.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43154 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194Ab1CGQgK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 11:36:10 -0500
In-Reply-To: <1299441608-25482-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  6 Mar 2011 21:00:08 +0100
Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr> wrote:

> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
> ---
> This apply on top of Jiri's last patch serie, including the last one =
that
> commented the RX_HANDLER_* values.
>=20
>  include/linux/netdevice.h |   53 +++++++++++++++++++++++++++++++++++=
+++------
>  net/core/dev.c            |    2 +
>  2 files changed, 47 insertions(+), 8 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 26e03f9..0c9dc93 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -390,15 +390,52 @@ enum gro_result {
>  };
>  typedef enum gro_result gro_result_t;
> =20
> +/**
> + * enum rx_handler_result - Possible return values for rx_handlers.
> + * @RX_HANDLER_CONSUMED: skb was consumed by rx_handler, do not proc=
ess it
> + * further.
> + * @RX_HANDLER_ANOTHER: Do another round in receive path. This is in=
dicated in
> + * case skb->dev was changed by rx_handler.
> + * @RX_HANDLER_EXACT: Force exact delivery, no wildcard.
> + * @RX_HANDLER_PASS: Do nothing, passe the skb as if no rx_handler w=
as called.

s/passe/process/
