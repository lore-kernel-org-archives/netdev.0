From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/3] gianfar_ptp: fix endianness in get_of_u32()
Date: Mon, 22 Feb 2016 09:35:59 +0100
Message-ID: <20160222083558.GB2138@netboy>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
 <1456123773-1016-3-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36665 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbcBVIgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 03:36:02 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so160312023wme.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 00:36:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456123773-1016-3-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 02:49:32PM +0800, Yangbo Lu wrote:
> @@ -431,7 +431,7 @@ static int get_of_u32(struct device_node *node, char *str, u32 *val)
>  
>  	if (!prop || plen != sizeof(*prop))
>  		return -1;
> -	*val = *prop;
> +	*val = be32_to_cpu(*prop);
>  	return 0;
>  }

Why not simply replace get_of_u32 with the standard helper function,
of_property_read_u32?

Thanks,
Richard
