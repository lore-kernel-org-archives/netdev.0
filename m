From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 01/12] xfrm: Introduce xfrm_input_afinfo to access
 the the callbacks properly
Date: Sun, 02 Mar 2014 20:09:23 -0500 (EST)
Message-ID: <20140302.200923.1500412807288633496.davem@davemloft.net>
References: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com>
	<1393583483-12480-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christophe.gouault@6wind.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbaCCBJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 20:09:24 -0500
In-Reply-To: <1393583483-12480-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 28 Feb 2014 11:31:11 +0100

> +	int err = 0;
> +	if (unlikely(afinfo == NULL))
> +		return -EINVAL;

A newline between local variable declarations and code, please.

> +	int err = 0;
> +	if (unlikely(afinfo == NULL))
> +		return -EINVAL;

Likewise.

> +	struct xfrm_input_afinfo *afinfo;
> +	if (unlikely(family >= NPROTO))
> +		return NULL;

Likewise.

> +	int ret;
> +	struct xfrm_input_afinfo *afinfo = xfrm_input_get_afinfo(family);
> +	if (!afinfo)
> +		return -EAFNOSUPPORT;

Likewise.
