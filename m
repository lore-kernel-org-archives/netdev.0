From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net] netlink: make sure -EBUSY won't escape from netlink_insert
Date: Thu, 17 Sep 2015 11:47:12 -0700
Message-ID: <CA+55aFxyqfxJphqDF_X4hG40b21XWP0fFdMhFJKn6riy5-kmtA@mail.gmail.com>
References: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
	<20150810.110015.1616067694505641781.davem@davemloft.net>
	<20150917054114.GN1983@Chimay.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Network Development <netdev@vger.kernel.org>
To: Christoph Paasch <christoph.paasch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36032 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbbIQSrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 14:47:13 -0400
Received: by ioii196 with SMTP id i196so32268508ioi.3
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 11:47:13 -0700 (PDT)
In-Reply-To: <20150917054114.GN1983@Chimay.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2015 at 10:41 PM, Christoph Paasch
<christoph.paasch@gmail.com> wrote:
>
> can this patch get queued up for 4.1 as well?
> It seems to fix a similar issue in 4.1.6.

I think Herbert has an additional patch for this issue. But yes, I
think should be scheduled for stable. Herbert?

                Linus
