From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 1/5] net/cadence: get rid of HAVE_NET_MACB
Date: Mon, 22 Oct 2012 08:59:17 +0200
Message-ID: <CAGhQ9VyPNDKWwGCZ2Mghm7dOcyTqTgL=ahv+1EQaXtz-Hd7OMg@mail.gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
	<1350829392-3812-2-git-send-email-manabian@gmail.com>
	<20121021.192707.1747557282711878897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nicolas.ferre@atmel.com, hskinnemoen@gmail.com,
	egtvedt@samfundet.no, plagnioj@jcrosoft.com, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35054 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab2JVG7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 02:59:19 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1439363lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 23:59:17 -0700 (PDT)
In-Reply-To: <20121021.192707.1747557282711878897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 1:27 AM, David Miller <davem@davemloft.net> wrote:
>
> You do know that this is going to generate warnings on 64-bit
> platforms?
>
> I was hoping you would have noticed and corrected this before
> enabling the driver everywhere, I guess my expectations were
> way too high :-/

ah, sorry.

Yes, macb seem to generate some integer overflows on ~0UL on 64-bit. I
have a patch that turns ~0UL into -1.

I can repost the series with fix included. Do you want me to do that?

regards
Joachim Eastwood
