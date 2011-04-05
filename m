From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 5/6] ethtool: Change ETHTOOL_PHYS_ID
 implementation to allow dropping RTNL
Date: Mon, 4 Apr 2011 18:01:23 -0700
Message-ID: <20110404180123.702bd14e@nehalam>
References: <1301859889.2935.23.camel@localhost>
	<1301860429.2935.29.camel@localhost>
	<1301959591.2935.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50660 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab1DEBB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 21:01:27 -0400
In-Reply-To: <1301959591.2935.64.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Apr 2011 00:26:31 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> This reimplementation lets us blink LEDs on multiple device at the same
> time, but that's pretty pointless.  The nasty thing is we could try to
> blink LEDs twice over on the same device, violating the rules that the
> drivers depend on.  So I think I need to add:
> 

This looks sane, is there a good way to fix the qlge and cxgb4 drivers
and get rid of the old interface?

-- 
