From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6] sfc: Really allow RX checksum offload to be
 disabled
Date: Wed, 28 Oct 2009 10:53:58 +0000
Message-ID: <1256727238.3136.205.camel@localhost>
References: <1256655057.2794.4.camel@achroite>
	 <1256672673.2794.7.camel@achroite>
	 <20091028.024940.181264224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28005 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbZJ1KyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:54:00 -0400
In-Reply-To: <20091028.024940.181264224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 02:49 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 27 Oct 2009 19:44:33 +0000
> 
> > We have never checked the efx_nic::rx_checksum_enabled flag everywhere
> > we should, and since the switch to GRO we don't check it anywhere.
> > It's simplest to check it in the one place where we initialise the
> > per-packet checksummed flag.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > Cc: stable@kernel.org
> > ---
> > I'm not sure whether this is serious enough to merit a stable update.
> > It's not a recent regression.
> 
> This patch only applies to net-next-2.6, so I can't see how it could
> be a -stable candidate :-)
> 
> So I've applied it there.

The register name update in net-next-2.6 changed the context for this
patch.  I'll send a new patch that will apply to the earlier versions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

