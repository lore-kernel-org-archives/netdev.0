From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/tun: fix ioctl() based info leaks
Date: Sun, 29 Jul 2012 23:20:30 -0700 (PDT)
Message-ID: <20120729.232030.2050276841156884872.davem@davemloft.net>
References: <CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
	<1343627114-17899-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.weinberger@gmail.com, netdev@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab2G3GUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:20:30 -0400
In-Reply-To: <1343627114-17899-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Mon, 30 Jul 2012 07:45:14 +0200

> The tun module leaks up to 36 bytes of memory by not fully initializing
> a structure located on the stack that gets copied to user memory by the
> TUNGETIFF and SIOCGIFHWADDR ioctl()s.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied and queued up for -stable, thanks.
