From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Ethtool: Beautify private flags print
Date: Thu, 23 May 2013 11:30:17 -0700
Message-ID: <1369333817.2075.34.camel@joe-AO722>
References: <1369331751-32543-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	eilong@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49145 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757989Ab3EWSaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 14:30:19 -0400
In-Reply-To: <1369331751-32543-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 20:55 +0300, Yuval Mintz wrote:
> When printing the private flags of the device, align all strings
> to have the same length.
[]
> diff --git a/ethtool.c b/ethtool.c
[]
> +	for (i = 0; i < strings->len; i++) {
> +		int j;
> +
> +		printf("%s", (const char *)strings->data +
> +					   i * ETH_GSTRING_LEN);
> +
> +		cur_len = strlen((const char*)strings->data +
> +					      i * ETH_GSTRING_LEN);
> +		for (j = 0; j < max_len - cur_len; j++)
> +			printf(" ");

I think this isn't necessary, but this is simpler

"%-*s", max_len, strings->data + i * ETH_GSTRING_LEN
