From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: ipv6_mapped needs sk_rx_dst_set method
Date: Sun, 19 Aug 2012 12:48:41 +0200
Message-ID: <1345373321.5158.76.camel@edumazet-glaptop>
References: <20120809160349.d2880b5a.akpm@linux-foundation.org>
	 <1344556733.31104.819.camel@edumazet-glaptop>
	 <1344557460.31104.863.camel@edumazet-glaptop>
	 <20120809.210600.638327100706973152.davem@davemloft.net>
	 <20120818130642.GA10680@thinkpad.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Artem Savkov <artem.savkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51658 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab2HSKsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 06:48:45 -0400
Received: by wgbdr13 with SMTP id dr13so4576261wgb.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 03:48:44 -0700 (PDT)
In-Reply-To: <20120818130642.GA10680@thinkpad.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-18 at 17:06 +0400, Artem Savkov wrote:

> It doesn't seem to fix the problem with mapped ipv6 completely.
> I'm still hitting a NULL pointer dereference with mapped ipv6:

Thanks Artem for the report, I see Neal took care of the problem.
