From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net] soreuseport: Fix TCP listener hash collision
Date: Thu, 28 Apr 2016 16:46:38 -0700
Message-ID: <1461887198.5535.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461885872-27358-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36472 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbcD1Xql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 19:46:41 -0400
Received: by mail-pf0-f171.google.com with SMTP id c189so40591912pfb.3
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 16:46:40 -0700 (PDT)
In-Reply-To: <1461885872-27358-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 19:24 -0400, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> I forgot to include a check for listener port equality when deciding
> if two sockets should belong to the same reuseport group.  This was
> not caught previously because it's only necessary when two listening
> sockets for the same user happen to hash to the same listener bucket.
> The same error does not exist in the UDP path.
> 
> Fixes: c125e80b8868("soreuseport: fast reuseport TCP socket selection")
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---

Thanks Craig

Acked-by: Eric Dumazet <edumazet@google.com>
