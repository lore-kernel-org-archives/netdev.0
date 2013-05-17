From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dev: remove duplicate 'skb->dev = dev' in
 dev_forward_skb()
Date: Fri, 17 May 2013 06:39:12 -0700
Message-ID: <1368797952.3301.85.camel@edumazet-glaptop>
References: <1368783392-21574-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:50466 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085Ab3EQNjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 09:39:14 -0400
Received: by mail-da0-f44.google.com with SMTP id z8so2364671daj.31
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 06:39:13 -0700 (PDT)
In-Reply-To: <1368783392-21574-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 11:36 +0200, Nicolas Dichtel wrote:
> This was added by commit 59b9997baba5 (Revert "net: maintain namespace
> isolation between vlan and real device").
> In fact, before the initial commit - the one that is reverted -, this
> statement was not present.
> 'skb->dev = dev' is already done in eth_type_trans(), which is call just
> after.
> 
> Spotted-by: Alain Ritoux <alain.ritoux@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
