From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/7] ptp: switch to use gpiolib
Date: Tue, 10 Sep 2013 16:19:13 +0200
Message-ID: <20130910141912.GB5088@netboy>
References: <1378816260-8091-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-gpio@vger.kernel.org, Imre Kaloz <kaloz@openwrt.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Alexandre Courbot <acourbot@nvidia.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:35996 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784Ab3IJOTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 10:19:20 -0400
Content-Disposition: inline
In-Reply-To: <1378816260-8091-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 10, 2013 at 02:31:00PM +0200, Linus Walleij wrote:
> This platform supports gpiolib, so remove the custom API use
> and replace with calls to gpiolib. Also request the GPIO before
> starting to use it.
> 
> Cc: Imre Kaloz <kaloz@openwrt.org>
> Cc: Krzysztof Halasa <khc@pm.waw.pl>
> Cc: Alexandre Courbot <acourbot@nvidia.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
> Hi Richard, I'm seeking an ACK on this patch to take it throug
> the GPIO tree as part of a clean-out of custom GPIO implementations.

I don't have this hardware for testing (it is really obsolete now),
but the change looks okay to me.

Acked-by: Richard Cochran <richardcochran@gmail.com>
