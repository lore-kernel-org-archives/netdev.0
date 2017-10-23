From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sun, 22 Oct 2017 21:31:03 -0700
Message-ID: <1508733063.30291.72.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508645419.9317.7.camel@klaipeden.com>
         <1508649690.30291.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508677159.3011.1.camel@klaipeden.com>
         <1508690944.30291.48.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508692270.30291.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508729177.2898.5.camel@klaipeden.com>
         <1508730005.30291.70.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508732925.2898.7.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:43789 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750802AbdJWEbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:31:05 -0400
Received: by mail-pf0-f171.google.com with SMTP id a8so16177137pfc.0
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 21:31:05 -0700 (PDT)
In-Reply-To: <1508732925.2898.7.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-23 at 13:28 +0900, Koichiro Den wrote:

> Indeed, meaning that tcp_clean_rtx_queue implementation never takes.
> But for me it seems that there is some possibility RACK algorithm will take it.

As long as tp->tcp_mstamp is monotonically increasing (and it is ;) ),
RACK will behave properly.

I am not sure we need to discuss this forever frankly ;)
 
