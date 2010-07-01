From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 2/2] ethtool: Add support for control of RX
 flow hash indirection
Date: Thu, 01 Jul 2010 17:03:45 +0100
Message-ID: <1278000225.2082.15.camel@achroite.uk.solarflarecom.com>
References: <1277910740.2082.17.camel@achroite.uk.solarflarecom.com>
	 <1277910792.2082.18.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21966 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757090Ab0GAQDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 12:03:48 -0400
In-Reply-To: <1277910792.2082.18.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 16:13 +0100, Ben Hutchings wrote:
> Many NICs use an indirection table to map an RX flow hash value to one
> of an arbitrary number of queues (not necessarily a power of 2).  It
> can be useful to remove some queues from this indirection table so
> that they are only used for flows that are specifically filtered
> there.  It may also be useful to weight the mapping to account for
> user processes with the same CPU-affinity as the RX interrupts.
[...]
> +	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
> +	       devname, ring_count.data);
> +	for (i = 0; i < indir->size; i++) {
> +		if (i % 8 == 0)
> +			printf("%5zu: ", i);
> +		printf(" %5u", indir->ring_index[i]);
> +		if (i % 8 == 7)
> +			fputc('\n', stdout);
> +	}
[...]

The "%5zu: " above should be "%5u: ".  I can either send another patch
or leave you to fix this up, as you prefer.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

