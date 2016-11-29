From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH  v2 08/13] net: ethernet: ti: cpts: move dt props parsing
 to cpts driver
Date: Tue, 29 Nov 2016 11:11:12 +0100
Message-ID: <20161129101112.GG3110@localhost.localdomain>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
 <20161128230337.6731-9-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34834 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755394AbcK2KLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 05:11:17 -0500
Content-Disposition: inline
In-Reply-To: <20161128230337.6731-9-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 05:03:32PM -0600, Grygorii Strashko wrote:
> +static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
> +{
> +	int ret = -EINVAL;
> +	u32 prop;
> +
> +	if (of_property_read_u32(node, "cpts_clock_mult", &prop))
> +		goto  of_error;
> +	cpts->cc_mult = prop;

Why not set cc.mult here at the same time?

> +
> +	if (of_property_read_u32(node, "cpts_clock_shift", &prop))
> +		goto  of_error;
> +	cpts->cc.shift = prop;
> +
> +	return 0;
> +
> +of_error:
> +	dev_err(cpts->dev, "CPTS: Missing property in the DT.\n");
> +	return ret;
> +}

Thanks,
Richard
