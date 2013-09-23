From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 11/11] sfc: Add static tracepoints to datapath
Date: Mon, 23 Sep 2013 19:34:49 +0100
Message-ID: <1379961289.2485.53.camel@bwh-desktop.uk.level5networks.com>
References: <1379788592.1681.45.camel@bwh-desktop.uk.level5networks.com>
	 <20130923.020838.2084214261543483443.davem@davemloft.net>
	 <1379951467.2485.33.camel@bwh-desktop.uk.level5networks.com>
	 <20130923.141723.230027899643613700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24674 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab3IWSex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:34:53 -0400
In-Reply-To: <20130923.141723.230027899643613700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 14:17 -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 23 Sep 2013 16:51:07 +0100
> 
> > 2. Generic trace events would be subject to changes that could make them
> > unsuitable for Solarflare's tests.
> 
> This is not an argument for doing things privately in your driver and
> duplicating things.
> 
> We should make a facility that's useful to Solarflare _AS WELL AS_
> everyone else.

OK, I'll try that.

> > 4. Static tracepoints always have run-time overhead, so these should
> > probably be controlled by a kconfig option (as in this patch).
> 
> Don't we use static branches and other tricks to make them close to zero
> overhead?

You're right, it is a static branch if CONFIG_JUMP_LABEL is enabled.
Some documentation has not been updated to reflect this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
