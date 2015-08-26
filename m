From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 5/5] net: dsa: bcm_sf2: Allow disabling tagging
 protocol
Date: Tue, 25 Aug 2015 17:09:07 -0700 (PDT)
Message-ID: <20150825.170907.650915573418643373.davem@davemloft.net>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
	<1440543015-14693-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755223AbbHZAJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 20:09:08 -0400
In-Reply-To: <1440543015-14693-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 25 Aug 2015 15:50:15 -0700

>  	/* Enable Broadcom tags for IMP port */
>  	reg = core_readl(priv, CORE_BRCM_HDR_CTRL);
> -	reg |= val;
> +	if (!tagging_disabled)

Just a pet-peeve of mine, I hate conditions that read as double
negatives, like this one does.
