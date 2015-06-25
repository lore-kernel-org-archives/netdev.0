From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [v2,8/9] fsl/fman: Add FMan Port Support
Date: Fri, 26 Jun 2015 01:28:49 +0200
Message-ID: <1435274929.28572.28.camel@tiscali.nl>
References: <1435174659-6876-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	madalin.bucur@freescale.com
To: igal.liberman@freescale.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud3.xs4all.net ([194.109.24.22]:56721 "EHLO
	lb1-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbbFYX2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 19:28:53 -0400
In-Reply-To: <1435174659-6876-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-24 at 22:37 +0300, igal.liberman@freescale.com wrote:
> --- a/drivers/net/ethernet/freescale/fman/fm_drv.c
> +++ b/drivers/net/ethernet/freescale/fman/fm_drv.c

> +struct fm_port_t *fm_port_drv_handle(const struct fm_port_drv_t *port)
> +{
> +	return port->fm_port;
> +}
> +EXPORT_SYMBOL(fm_port_drv_handle);

I couldn't find any users of this function.

> +void fm_port_get_buff_layout_ext_params(struct fm_port_drv_t *port,
> +> 	> 	> 	> 	> 	struct fm_port_params *params)

(Evolution 3.16 is a piece of ...).

> +{
> +	params->data_align = 0;
> +}
> +EXPORT_SYMBOL(fm_port_get_buff_layout_ext_params);

Ditto.

> +int fm_get_tx_port_channel(struct fm_port_drv_t *port)
> +{
> +	return port->tx_ch;
> +}
> +EXPORT_SYMBOL(fm_get_tx_port_channel);

Ditto.

> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/fman/fm_port_drv.c

> +void fm_set_rx_port_params(struct fm_port_drv_t *port,
> +			   struct fm_port_params *params)
> +{
+	[...]
> +}
> +EXPORT_SYMBOL(fm_set_rx_port_params);

Ditto.

(If you hear about my arrest for randomly attacking innocent people:
blame evolution 3.16!)

> +void fm_set_tx_port_params(struct fm_port_drv_t *port,
> +			   struct fm_port_params *params)
> +{
> +	[...]
> +}
> +EXPORT_SYMBOL(fm_set_tx_port_params);

Ditto.

> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/fman/port/fm_port.c

> +u64 *fm_port_get_buffer_time_stamp(const struct fm_port_t *p_fm_port,
> +				   char *p_data)
> +{
> +	[...]
> +}
> +EXPORT_SYMBOL(fm_port_get_buffer_time_stamp);

Ditto.

> +int fm_port_disable(struct fm_port_t *p_fm_port)
> +{
> +	[...]
> +}
> +EXPORT_SYMBOL(fm_port_disable);

This exports a function that I think is only used inside this file.

> +int fm_port_enable(struct fm_port_t *p_fm_port)
> +{
> +	[...]
> +}
> +EXPORT_SYMBOL(fm_port_enable);

And here I could again find no users of this function.

Thanks,


Paul Bolle
