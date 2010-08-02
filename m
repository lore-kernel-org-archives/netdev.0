From: Florian Westphal <fw@strlen.de>
Subject: Re: why do we need printk on sending syn flood cookie?
Date: Mon, 2 Aug 2010 10:17:16 +0200
Message-ID: <20100802081716.GA8374@Chamillionaire.breakpoint.cc>
References: <480391280735894@web102.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Franchoze Eric <franchoze@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:44605 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751857Ab0HBIRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 04:17:17 -0400
Content-Disposition: inline
In-Reply-To: <480391280735894@web102.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Franchoze Eric <franchoze@yandex.ru> wrote:
>  Just sirious why do we need printk each 1 second (60*HZ) about possible syn-flood? It really floods dmesg. Is there something dengerous? I have suggestion to turn off printk about sending tcp cookie each 1 second.

It is handled exactly like other printks in the networking path,
e.g. receipt of tcp wscale == 15.

Why does this need special treatment?
