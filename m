From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 5/6] ethtool: Change ETHTOOL_PHYS_ID
 implementation to allow dropping RTNL
Date: Tue, 05 Apr 2011 21:21:38 +0100
Message-ID: <1302034898.2932.119.camel@bwh-desktop>
References: <1301859889.2935.23.camel@localhost>
	 <1301860429.2935.29.camel@localhost> <1301959591.2935.64.camel@localhost>
	 <20110404180123.702bd14e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28369 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab1DEUVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 16:21:42 -0400
In-Reply-To: <20110404180123.702bd14e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 18:01 -0700, Stephen Hemminger wrote:
> On Tue, 05 Apr 2011 00:26:31 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > This reimplementation lets us blink LEDs on multiple device at the same
> > time, but that's pretty pointless.  The nasty thing is we could try to
> > blink LEDs twice over on the same device, violating the rules that the
> > drivers depend on.  So I think I need to add:
> > 
> 
> This looks sane, is there a good way to fix the qlge and cxgb4 drivers
> and get rid of the old interface?

Prod the respective maintainers?

(Wow, using device firmware to implement a delay, that's special.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

