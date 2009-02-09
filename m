From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Mon, 09 Feb 2009 00:29:40 -0800 (PST)
Message-ID: <20090209.002940.28474373.davem@davemloft.net>
References: <46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
	<20090208.234502.197065045.davem@davemloft.net>
	<46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: risto.suominen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbZBII3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 03:29:46 -0500
In-Reply-To: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Risto Suominen <risto.suominen@gmail.com>
Date: Mon, 9 Feb 2009 10:22:15 +0200

> Sounds good, but does not seem to help. My theory is that when the cpu
> is writing to one descriptor, it accidentally overwrites another
> descriptor, that has already been written to by the device, as there
> is only a single dirty bit, that makes the whole cacheline to be
> flushed.

You tested with 2.6.18 but you want me to apply this to current
kernels, that won't work.

Therefore you'll need to verify that the problem still exists with
current kernels before I'll consider this seriously.
