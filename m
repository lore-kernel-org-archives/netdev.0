From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 3/3] eth: Rename and properly align br_reserved_address
 array
Date: Thu, 01 Nov 2012 17:33:55 -0700
Message-ID: <509314F3.6030206@intel.com>
References: <1351797122.2883.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63298 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab2KBAd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 20:33:58 -0400
In-Reply-To: <1351797122.2883.14.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/2012 12:12 PM, Ben Hutchings wrote:
> Since this array is no longer part of the bridge driver, it should
> have an 'eth' prefix not 'br'.
>
> We also assume that either it's 16-bit-aligned or the architecture has
> efficient unaligned access.  Ensure the first of these is true by
> explicitly aligning it.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

Thanks.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
