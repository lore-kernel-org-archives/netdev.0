From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: Ensure that initialization is done prior to request_irq()
Date: Thu, 21 Feb 2013 17:29:46 -0300
Message-ID: <CAOMZO5ArHJy=KN8R5F0cOhDN=MnxRTmBUOgDsn8zutrTNw=igg@mail.gmail.com>
References: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com>
	<20130221.152724.6508078801736235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fabio.estevam@freescale.com, Frank.Li@freescale.com,
	s.hauer@pengutronix.de, jim_baxter@mentor.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:46806 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757709Ab3BUU3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 15:29:48 -0500
Received: by mail-wi0-f179.google.com with SMTP id ez12so120406wid.6
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 12:29:47 -0800 (PST)
In-Reply-To: <20130221.152724.6508078801736235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 5:27 PM, David Miller <davem@davemloft.net> wrote:

> Looks good, did you test this yourself or should we wait for others to
> test it out?

Yes, I tested it myself. I was the one who reported this bug and this
fixes the problem.
