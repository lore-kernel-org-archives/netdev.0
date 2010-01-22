From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 11/13] net-caif: add CAIF Kconfig and
 Makefiles
Date: Fri, 22 Jan 2010 10:40:42 +0100
Message-ID: <1264153242.3469.31.camel@violet>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1264028130-14364-12-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45496 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786Ab0AVJjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:39:42 -0500
In-Reply-To: <1264028130-14364-12-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> +config CAIF_SOCK
> +	tristate "CAIF Sockets"
> +	default CAIF
> +	---help---
> +	Say Y if you will be using CAIF Sockets.
> +	This can be either built-in or a loadable module,
> +	If you select to build it as a built-in then the main CAIF device must
> +	also be a built-in,
> +	If unsure say Y.
> +
> +config CAIF_NETDEV
> +	tristate "CAIF GPRS Network device"
> +	default CAIF
> +	---help---
> +	Say Y if you will be using a CAIF based GPRS network device.
> +	This can be either built-in or a loadable module,
> +	If you select to build it as a built-in then the main CAIF device must
> +	also be a built-in.
> +	If unsure say Y.

any real use cases where NOT building CAIF_SOCK would make sense. Maybe
it would be better to move CAIF_SOCK and CAIF_NETDEV under EMBEDDED.

Regards

Marcel


