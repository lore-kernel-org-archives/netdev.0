From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] net: Discard and warn about LRO'd skbs received for
 forwarding
Date: Thu, 19 Jun 2008 14:50:15 -0700
Message-ID: <20080619145015.3ec2307c@extreme>
References: <cover.1213898165.git.bhutchings@solarflare.com>
	<20080619180833.GU5350@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42955 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832AbYFSVuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 17:50:17 -0400
In-Reply-To: <20080619180833.GU5350@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jun 2008 19:08:34 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Add skb_warn_if_lro() to test whether an skb was received with LRO and
> warn if so.
> 
> Change br_forward(), ip_forward() and ip6_forward() to call it) and
> discard the skb if it returns true.

Actually shouldn't ip forwarding work because of refragmentation?
