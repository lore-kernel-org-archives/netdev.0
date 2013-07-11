From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add a rate_limit attribute to netdev_queue
 and a rtnetlink
Date: Thu, 11 Jul 2013 16:35:01 -0700 (PDT)
Message-ID: <20130711.163501.353724739279106871.davem@davemloft.net>
References: <20130710140409.6691.77084.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, therbert@google.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab3GKXfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 19:35:03 -0400
In-Reply-To: <20130710140409.6691.77084.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 10 Jul 2013 07:04:12 -0700

> /* Queue Attributes management
>  *      Nested layout of queue attributes is:
>  *      [IFLA_QUEUE_ATTRIBS]
>  *              [IFLA_QUEUE_ATTRIB]
>  *                      [IFLA_QUEUE_INDEX]      <required>
>  *                      [IFLA_QUEUE_RATE]       <optional>
>  *              [IFLA_QUEUE_ATTRIB]
>  *                      [...]
>  */

Since these are specifically TX queue attributes, and not
RX queue attributes, please add "_TX_" in the names both
of the attributes themselves and the ->ndo_*() method.

> +static const struct nla_policy ifla_queue_policy[IFLA_QUEUE_MAX+1] = {
> +	[IFLA_QUEUE_INDEX]	= { .type = NLA_U32},
> +	[IFLA_QUEUE_RATE]	= { .type = NLA_U32},
> +};

Space needed after NLA_U32 and the closing brace.
