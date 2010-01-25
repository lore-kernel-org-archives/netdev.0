From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1 V4] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC
 driver
Date: Mon, 25 Jan 2010 08:37:59 -0800
Message-ID: <20100125083759.3392e2ff@nehalam>
References: <1264417272-3800-1-git-send-email-kristoffer@gaisler.com>
	<1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34250 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456Ab0AYQiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 11:38:10 -0500
In-Reply-To: <1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2010 12:01:12 +0100
Kristoffer Glembo <kristoffer@gaisler.com> wrote:

> +/* Wait for a register change with a timeout, jiffies used has time reference */
> +#define wait_loop(wait_statement, timeout, label_on_timeout, arg_on_timeout) \
> +	{ \
> +		unsigned long _timeout = jiffies + HZ/100*timeout; \
> +		while (wait_statement) { \
> +			if (time_after(jiffies, _timeout)) { \
> +				arg_on_timeout; \
> +goto label_on_timeout; \
> +			} \
> +		} \
> +	}

Ugly macro used with same arguments, just write a single function

-- 
