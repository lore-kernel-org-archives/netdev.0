From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/4] net: af_unix: implement stream sendpage
 support
Date: Thu, 21 May 2015 07:11:54 -0700
Message-ID: <1432217514.4060.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1432200343.git.hannes@stressinduktion.org>
	 <b41cc15175028ef651f0a603fd53f037efc2b6fb.1432200344.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, cwang@twopensource.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38257 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189AbbEUOL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 10:11:56 -0400
Received: by igcau1 with SMTP id au1so9430846igc.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 07:11:56 -0700 (PDT)
In-Reply-To: <b41cc15175028ef651f0a603fd53f037efc2b6fb.1432200344.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 11:39 +0200, Hannes Frederic Sowa wrote:
> This patch implements sendpage support for AF_UNIX SOCK_STREAM
> sockets. This is also required for a complete splice implementation.
> 
> The implementation is a bit tricky because we append to already existing
> skbs and so have to hold unix_sk->readlock to protect the reading side
> from either advancing UNIXCB.consumed or freeing the skb at the socket
> receive tail.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
