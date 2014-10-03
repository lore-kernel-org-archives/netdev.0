From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] pgtable: Add API to query if write
 combining is available
Date: Fri, 03 Oct 2014 12:31:59 -0700 (PDT)
Message-ID: <20141003.123159.1606594798918755956.davem@davemloft.net>
References: <1412175282-25212-1-git-send-email-ogerlitz@mellanox.com>
	<1412175282-25212-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, moshel@mellanox.com, talal@mellanox.com,
	yevgenyp@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbaJCT3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 15:29:54 -0400
In-Reply-To: <1412175282-25212-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  1 Oct 2014 17:54:41 +0300

> +#define writecombine_available writecombine_available
> +static inline int writecombine_available(void)
> +{
> +	return 1;
> +}
> +

Please use 'bool' and 'true'/'false'.
