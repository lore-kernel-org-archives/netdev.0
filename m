From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] tcp: Initial repair mode
Date: Wed, 28 Mar 2012 21:39:18 +0100
Message-ID: <1332967158.2624.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F732FE1.9040906@parallels.com>
	 <4F73302C.9030209@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:21296 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756786Ab2C1UjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 16:39:22 -0400
In-Reply-To: <4F73302C.9030209@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-28 at 19:37 +0400, Pavel Emelyanov wrote:
[...]
> * Ability to forcibly bind a socket to a port
> 
> The sk->sk_reuse is set to 2 denoting, that the socket is question
> should be bound as if all the others in the system are configured
> with the SO_REUSEADDR option.

Shouldn't this constant be named?

[...]
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
[...]
> +	case TCP_REPAIR_QUEUE:
> +		if (!tp->repair)
> +			err = -EPERM;
> +		else if (val <= TCP_QUEUES_NR)

Off-by-one.

> +			tp->repair_queue = val;
> +		else
> +			err = -EINVAL;
> +		break;
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
