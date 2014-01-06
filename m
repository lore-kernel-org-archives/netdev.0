From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 5/5] alx: add stats to ethtool
Date: Mon, 06 Jan 2014 10:03:10 +0100
Message-ID: <1388998990.5891.0.camel@jlt4.sipsolutions.net>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
	 <1388854031-24142-6-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41898 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbaAFJDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 04:03:24 -0500
In-Reply-To: <1388854031-24142-6-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-04 at 17:47 +0100, Sabrina Dubroca wrote:

> +	__alx_update_hw_stats(hw);
> +	BUILD_BUG_ON(sizeof(hw->stats) - offsetof(struct alx_hw_stats, rx_ok) <
> +		     ALX_NUM_STATS * sizeof(u64));

I think you should make that != instead of <, otherwise you won't catch
all possible differences.

johannes
