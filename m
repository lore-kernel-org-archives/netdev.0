From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 11:27:59 -0400
Message-ID: <1309102079.5134.27.camel@mojatatu>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309097862.5134.26.camel@mojatatu>  <1309100033.3093.1499.camel@localhost>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:63552 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab1FZP2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 11:28:02 -0400
Received: by iwn6 with SMTP id 6so3511030iwn.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 08:28:02 -0700 (PDT)
In-Reply-To: <1309100033.3093.1499.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-26 at 15:53 +0100, Ben Hutchings wrote:

> These variable names seem to be the wrong way round, i.e. the weight is
> our 'quota' and the number of packets dequeued is the 'work' we've done.

Makes sense - I will make the change.

cheers,
jamal

