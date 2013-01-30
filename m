From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v4 1/1 net-next] net: fec: add napi support to improve proformance
Date: Wed, 30 Jan 2013 09:55:03 +0800
Message-ID: <CAHrpEqQXH+n7K4L1m5yRiamp3CG9MPWhX+tNBD+brzArJy5WoQ@mail.gmail.com>
References: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com>
	<20130129.141800.2181207237672109119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank.Li@freescale.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:36616 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241Ab3A3BzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 20:55:06 -0500
Received: by mail-wg0-f50.google.com with SMTP id es5so778339wgb.17
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 17:55:04 -0800 (PST)
In-Reply-To: <20130129.141800.2181207237672109119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/30 David Miller <davem@davemloft.net>:
> it is recommended to also to TX reclaim processing
> in the NAPI handler as well, in fact it's best to make the hardware
> interrupt handler do nothing other than trigger NAPI and then
> move everything that was in your hardware interrupt handler into
> NAPI poll instead.

Okay, I will work on this soon.
