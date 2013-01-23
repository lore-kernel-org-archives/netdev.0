From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/2 net-next] net: fec: add napi support to improve proformance
Date: Wed, 23 Jan 2013 16:00:55 +0800
Message-ID: <CAHrpEqRkxr_R4BuWjpRV3yBUOsedqVPdLK3K6+9w4xoUTRHwEg@mail.gmail.com>
References: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
	<20130123072635.GO1906@pengutronix.de>
	<CAHrpEqQ3-prqJaCmt1hfOr4GzDVyuRNvko1SCyQZHdALhHkhkw@mail.gmail.com>
	<20130123075323.GU1906@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank Li <Frank.Li@freescale.com>, shawn.guo@linaro.org,
	B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:61705 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab3AWIA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 03:00:56 -0500
Received: by mail-wi0-f176.google.com with SMTP id hm6so434842wib.3
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 00:00:55 -0800 (PST)
In-Reply-To: <20130123075323.GU1906@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why do you want to make it configurable anyway? So far no other driver
> seems to need this. My suggestion is to make it unconfigurable.
>
> For adding properties like this to the devicetree remember that they
> should be OS agnostic. napi is a implementation detail relevant only
> for Linux. And even Linux may decide to drop napi support in favour for
> something better in the future.
>

Okay, I will remove such config in v2 version.

best regards
Frank Li
