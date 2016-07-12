From: Masashi Honma <masashi.honma@gmail.com>
Subject: Re: [PATCH v2 net-next] rtnl: Add GFP flag argument to rtnl_unicast()
Date: Tue, 12 Jul 2016 13:23:43 +0900
Message-ID: <578470CF.6060609@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
 <1468036744-3964-1-git-send-email-masashi.honma@gmail.com>
 <20160711.130147.2231877907183030717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36167 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbcGLEXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 00:23:47 -0400
Received: by mail-pa0-f45.google.com with SMTP id hu1so2122396pad.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 21:23:47 -0700 (PDT)
In-Reply-To: <20160711.130147.2231877907183030717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016=E5=B9=B407=E6=9C=8812=E6=97=A5 05:01, David Miller wrote:

> The code is correct and optimal as-is.  There is no gain to your
> changes.  gfp_any() will do the right thing.
>
> In fact, your change makes the code more error prone because if any
> of these code paths get moved into an atomic context they will break
> unless somone remembers to also fix up the GFP flags.
>
> Meanwhile with the existing use of gfp_any() it will work
> transparently in such a situation.
>
> I'm not applying this.

I see. Thank you for reviewing.
