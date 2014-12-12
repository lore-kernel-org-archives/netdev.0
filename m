From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 17:03:40 +0100
Message-ID: <20141212160340.GI16916@distanz.ch>
References: <1418400022-6264-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, netdev@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:37198 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934975AbaLLQDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 11:03:43 -0500
Content-Disposition: inline
In-Reply-To: <1418400022-6264-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-12 at 17:00:22 +0100, Tobias Klauser <tklauser@distanz.ch> wrote:
> If GPIOLIB=n the following build error occurs:

Sorry, I forgot to paste the following error message here:

drivers/net/ethernet/smsc/smc91x.c: In function 'try_toggle_control_gpio':
drivers/net/ethernet/smsc/smc91x.c:2204:2: error: implicit declaration of function 'devm_gpiod_get_index' [-Werror=implicit-function-declaration]
drivers/net/ethernet/smsc/smc91x.c:2204:7: warning: assignment makes pointer from integer without a cast [enabled by default]
drivers/net/ethernet/smsc/smc91x.c:2213:2: error: implicit declaration of function 'gpiod_direction_output' [-Werror=implicit-function-declaration]
drivers/net/ethernet/smsc/smc91x.c:2216:3: error: implicit declaration of function 'devm_gpiod_put' [-Werror=implicit-function-declaration]
drivers/net/ethernet/smsc/smc91x.c:2222:2: error: implicit declaration of function 'gpiod_set_value_cansleep' [-Werror=implicit-function-declaration]

I'll send an updated patch. Please disregard this one.
