From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/2 net-next] net: fec: add napi support to improve proformance
Date: Wed, 23 Jan 2013 15:44:53 +0800
Message-ID: <CAHrpEqQ3-prqJaCmt1hfOr4GzDVyuRNvko1SCyQZHdALhHkhkw@mail.gmail.com>
References: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
	<20130123072635.GO1906@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank Li <Frank.Li@freescale.com>, shawn.guo@linaro.org,
	B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44710 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685Ab3AWHoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 02:44:54 -0500
Received: by mail-we0-f174.google.com with SMTP id r6so857742wey.19
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 23:44:53 -0800 (PST)
In-Reply-To: <20130123072635.GO1906@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This comment seems rather unnecessary. Also it should be
>
>         /* space left and right /*
>
> devicetree bindings should use '-' instead of '_'. The binding
> Documentation should be in the patch adding the bindings. Also
> make sure the devicetree parsing is outside of the path for platform
> based probing.
>
> With this particular binding I'm unsure it should exist anyway since
> it's configuration rather than hardware description. The devicetree
> normally is for hardware description only.
>

What's your opinion?
Using module parameter, device-tree to config it or the other method?

best regards
Frank Li
