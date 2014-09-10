From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [Patch v2 net-next 09/12] net: fec: change FEC alignment
 according to i.mx6 sx requirement
Date: Wed, 10 Sep 2014 09:51:24 -0300
Message-ID: <CAOMZO5AwOWr8uWCvt3XzM8CJideu+1LBY6QUQ772QjLjCYxL1w@mail.gmail.com>
References: <1410293743-27874-1-git-send-email-Frank.Li@freescale.com>
	<1410293743-27874-10-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Duan Fugang-B38611 <b38611@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?5p2O5pm6?= <lznuaa@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:58772 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaIJMv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:51:26 -0400
In-Reply-To: <1410293743-27874-10-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2014 at 5:15 PM, Frank Li <Frank.Li@freescale.com> wrote:

> +       fep->rx_align = 0x3;
> +       fep->tx_align = 0x3;

Why do you unconditionally set it as 0x3? It was 0xf for ARM and 0x3
for non-ARM.
