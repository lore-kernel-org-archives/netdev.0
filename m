From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: unify tcp flag macros
Date: Sat, 12 Jun 2010 14:17:15 -0700 (PDT)
Message-ID: <20100612.141715.220059291.davem@davemloft.net>
References: <1276322372-12584-1-git-send-email-xiaosuo@gmail.com>
	<alpine.LSU.2.01.1006121017380.28286@obet.zrqbmnf.qr>
	<AANLkTikZSn5zJYNPU2mdcBiyY7jfBOvq0f1khlbue4JD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752343Ab0FLVRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 17:17:06 -0400
In-Reply-To: <AANLkTikZSn5zJYNPU2mdcBiyY7jfBOvq0f1khlbue4JD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sat, 12 Jun 2010 17:21:09 +0800

> The same macros are definied by BSDs too. So I think it is better to
> keep them the same.

That is an absolutely meaningless argument.

This is a "net/*.h" header, not something in "linux/*.h"
that application in userspace might want access to.

It's entirely private to the kernel, therefore we do what
makes the most sense (from a cleanliness and namespace
perspective) rather than "what other people do."
