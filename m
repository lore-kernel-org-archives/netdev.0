From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 stateless address autoconfiguration
Date: Mon, 12 May 2008 10:00:21 -0700
Message-ID: <OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com>
References: <20080513.004620.117676648.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Joseph.Bonitch@xerox.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:57290 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbYELRAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 13:00:47 -0400
In-Reply-To: <20080513.004620.117676648.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +         } else if (~rt_expires) {
> +            /* not infinity */
> +            rt->rt6i_expires = jiffies + rt_expires;
> +            rt->rt6i_flags |= RTF_EXPIRES;

        rt_expires is "unsigned long" -- won't the high-order
bits be set on 64-bit machines?
        Also, don't you need to check before the divide by
USER_HZ?

                                                        +-DLS


