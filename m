From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: secure_seq: Fix warning when CONFIG_IPV6 and
 CONFIG_INET are not selected
Date: Mon, 07 Oct 2013 15:59:53 -0400 (EDT)
Message-ID: <20131007.155953.607467271817129788.davem@davemloft.net>
References: <1381006619-17126-1-git-send-email-festevam@gmail.com>
	<1381006619-17126-2-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, olof@lixom.net, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754Ab3JGT7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:59:55 -0400
In-Reply-To: <1381006619-17126-2-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Sat,  5 Oct 2013 17:56:59 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> net_secret() is only used when CONFIG_IPV6 or CONFIG_INET are selected.
> 
> Building a defconfig with both of these symbols unselected (Using the ARM
> at91sam9rl_defconfig, for example) leads to the following build warning:
 ...
> Fix this warning by protecting the definition of net_secret() with these
> symbols.
> 
> Reported-by: Olof Johansson <olof@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> Changes since v1:
> - Add #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)

This looks a lot better, applied, thanks.
