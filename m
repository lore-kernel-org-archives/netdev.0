From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sat, 21 Oct 2017 20:52:53 -0700
Message-ID: <1508644373.30291.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:48707 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdJVDwz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 23:52:55 -0400
Received: by mail-pf0-f176.google.com with SMTP id b79so14759521pfk.5
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 20:52:55 -0700 (PDT)
In-Reply-To: <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-21 at 20:52 -0700, Eric Dumazet wrote:

> Very nice catch, thanks a lot Koichiro.
> 
> This IMO would target net tree, since it is a bug fix.
> 
> Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")

Reviewed-by: Eric Dumazet <edumazet@google.com>
