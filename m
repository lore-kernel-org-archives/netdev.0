From: Koichiro Den <den@klaipeden.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Mon, 23 Oct 2017 13:36:58 +0900
Message-ID: <1508733418.2898.8.camel@klaipeden.com>
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
         <1508733063.30291.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21404 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbdJWEhE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:37:04 -0400
In-Reply-To: <1508733063.30291.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-22 at 21:31 -0700, Eric Dumazet wrote:
> On Mon, 2017-10-23 at 13:28 +0900, Koichiro Den wrote:
> 
> > Indeed, meaning that tcp_clean_rtx_queue implementation never takes.
> > But for me it seems that there is some possibility RACK algorithm will take
> > it.
> 
> As long as tp->tcp_mstamp is monotonically increasing (and it is ;) ),
> RACK will behave properly.
> 
> I am not sure we need to discuss this forever frankly ;)
>  
> 
> 
Yeah, sure, thanks for your time and helpful comments.
