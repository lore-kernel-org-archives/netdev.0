From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Tue, 03 Dec 2013 08:54:38 +0100
Message-ID: <529D8E3E.2050009@linutronix.de>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de> <529D89EF.1000507@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Fugang Duan <B38611@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:49271 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab3LCHym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 02:54:42 -0500
In-Reply-To: <529D89EF.1000507@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2013 08:36 AM, Marek Szyprowski wrote:
> Hello,
Hi,

> I'm sorry for a delay. The check has been removed during conversion t=
o
> common,
> generic dma_map_ops implementation. During those convesion
> dma_(un)map_single
> calls have been implemented on top of dma_(un)map_page operation, wha=
t
> removed
> those additional check (*_page based function didn't have such check)=
=2E I
> agree
> that it might be a good idea to bring them back conditionally under
> CONFIG_DMA_DEBUG. Would you like to send a respective patch?

Yes, but it will take a while=E2=80=A6

> Best regards

Sebastian
