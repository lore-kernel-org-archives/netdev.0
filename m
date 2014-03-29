From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net] bridge: Fix memory leak in br_dev_xmit
Date: Sat, 29 Mar 2014 16:40:47 +0900
Message-ID: <1396078847.1756.1.camel@localhost.localdomain>
References: <1395987680-8151-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <20140328093457.5d25b9a3@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41625 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaC2Hkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 03:40:53 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so5998885pbb.33
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2014 00:40:53 -0700 (PDT)
In-Reply-To: <20140328093457.5d25b9a3@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 09:34 -0700, Stephen Hemminger wrote:
> On Fri, 28 Mar 2014 15:21:19 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
> > When a frame is rejected by br_allowed_ingress(), the skb is not freed.
> > 
...
> Increment dev->tx_dropped?

OK, I'll rework it.

Thanks,
Toshiaki Makita
