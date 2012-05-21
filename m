From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Mon, 21 May 2012 19:46:59 +0100
Message-ID: <20120521194659.04461096@bob.linux.org.uk>
References: <20120520164114.GD21177@windriver.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6F13@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"Ondrej Zary" <linux@rainbow-software.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14786 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750728Ab2EUSbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2012 14:31:47 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F13@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Probing for non-pnp ISA cards is definitely unreliable.
> Maybe some of these drivers should need to be explicitly
> enabled in the kernel config.

The config is set by the distributions, not always cluefully. Non PnP
ISA drivers won't autoload either as they have nothing to key off.

> I hadn't realised how bad some of the 3cxxx cards were!

The 3c500/01 were the first PC ethernet card ever so very very old.

> I thought the 'parallel tasking' was all about starting
> to tx a frame while the host was still copting it to the
> tx fifo (and rx copies before end of frame), not that

It was.

Alan
