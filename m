From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/4] r8169: explicit firmware format check.
Date: Fri, 17 Jun 2011 22:16:45 +0100
Message-ID: <1308345405.2831.34.camel@bwh-desktop>
References: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
	 <20110617193105.GB2287@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:4005 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab1FQVQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 17:16:50 -0400
In-Reply-To: <20110617193105.GB2287@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 21:31 +0200, Francois Romieu wrote:
[...]
> -	if (fw->size % sizeof(*phytable)) {
> -		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
> +	if (!rtl_fw_format_ok(tp, rtl_fw)) {
> +		netif_err(tp, probe, dev, "invalid firwmare\n");
[...]

Also, there's a typo in this error message.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

