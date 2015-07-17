From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rhashtable: Allow other tasks to be scheduled
 in large lookup loops
Date: Fri, 17 Jul 2015 10:50:21 +0200
Message-ID: <20150717085021.GA14796@pox.localdomain>
References: <2dcec22264c46d248e4f56ac5dfd6a8d321b162f.1437120351.git.tgraf@suug.ch>
 <1437121457.1026.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <1437121713.1026.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, mroos@linux.ee,
	herbert@gondor.apana.org.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33544 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946156AbbGQIuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 04:50:24 -0400
Received: by widic2 with SMTP id ic2so33902738wid.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 01:50:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437121713.1026.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/15 at 10:28am, Eric Dumazet wrote:
> On Fri, 2015-07-17 at 10:24 +0200, Eric Dumazet wrote:
> 
> > Please simply use cond_resched() without counting and magic value.

Done

> Also use cond_resched() in insert and delete phases ?

When I tried that it made the walker duplicates disappear which weakens
the test case a little bit but it's probably safer this way.  I'll include
it in the v2.
