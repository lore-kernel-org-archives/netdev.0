From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH NEXT 2/2] netxen: support for GbE port settings
Date: Mon, 11 Apr 2011 23:56:38 +0100
Message-ID: <1302562598.5282.573.camel@localhost>
References: <1299840277-30591-1-git-send-email-amit.salecha@qlogic.com>
	 <1299840277-30591-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13841 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab1DKW4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 18:56:42 -0400
In-Reply-To: <1299840277-30591-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-11 at 02:44 -0800, Amit Kumar Salecha wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> o Allow setting speed and auto negotiation parameters for GbE ports.
> o Log an error message to indicate duplex setting is not supported in
>   the hardware currently.
[...]
> +	ret = nx_fw_cmd_set_gbe_port(adapter, ecmd->speed, ecmd->duplex,
> +				     ecmd->autoneg);
> +	if (ret == NX_RCODE_NOT_SUPPORTED && ecmd->duplex == DUPLEX_HALF) {
> +		netdev_info(dev, "Speed and autoneg mode settings supported, "
> +			    "half duplex mode not supported\n");
>  		return -EOPNOTSUPP;
[...]

Should be -EINVAL.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

