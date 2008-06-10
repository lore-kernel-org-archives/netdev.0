From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [patch 06/13] fec_mpc52xx: MPC52xx_MESSAGES_DEFAULT: 2nd NETIF_MSG_IFDOWN => IFUP
Date: Mon, 9 Jun 2008 18:55:09 -0600
Message-ID: <fa686aa40806091755q3b2700b1w79f6e2d1c28fc08e@mail.gmail.com>
References: <200806092333.m59NXpvs014683@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, roel.kluin@gmail.com,
	tnt@246tnt.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:26648 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbYFJAzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 20:55:10 -0400
Received: by an-out-0708.google.com with SMTP id d40so557700and.103
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2008 17:55:09 -0700 (PDT)
In-Reply-To: <200806092333.m59NXpvs014683@imap1.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 9, 2008 at 5:33 PM,  <akpm@linux-foundation.org> wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
>
> Duplicate NETIF_MSG_IFDOWN, 2nd should be NETIF_MSG_IFUP
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Acked-by: Sylvain Munaut <tnt@246tNt.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  drivers/net/fec_mpc52xx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -puN drivers/net/fec_mpc52xx.c~fec_mpc52xx-mpc52xx_messages_default-2nd-netif_msg_ifdown-=-ifup drivers/net/fec_mpc52xx.c
> --- a/drivers/net/fec_mpc52xx.c~fec_mpc52xx-mpc52xx_messages_default-2nd-netif_msg_ifdown-=-ifup
> +++ a/drivers/net/fec_mpc52xx.c
> @@ -78,7 +78,7 @@ module_param_array_named(mac, mpc52xx_fe
>  MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
>
>  #define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
> -               NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFDOWN )
> +               NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP)
>  static int debug = -1; /* the above default */
>  module_param(debug, int, 0);
>  MODULE_PARM_DESC(debug, "debugging messages level");
> _
>



-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
