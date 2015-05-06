From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 0/8] Convert some skb_<foo> functions to
 void
Date: Wed, 06 May 2015 05:19:39 -0700
Message-ID: <1430914779.14545.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1430769294.git.joe@perches.com>
	 <1430771550.2872.7.camel@perches.com>
	 <20150505.192003.2226565044238098170.davem@davemloft.net>
	 <1430869128.9365.67.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33644 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbbEFMTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 08:19:42 -0400
Received: by iepj10 with SMTP id j10so8739926iep.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 05:19:41 -0700 (PDT)
In-Reply-To: <1430869128.9365.67.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-05 at 16:38 -0700, Joe Perches wrote:

> 
> Another thing that's fairly common is an skb_put followed by
> a memcpy or memset.
> 
> Adding a couple of functions for those like:
> 
> void *skb_put_memcpy(struct sk_buff *skb, void *from, size_t size);
> void *skb_put_memset(struct sk_buff *skb, int c, size_t size);
> 
> would reduce code size and improve performance a little.
> 
> Are you OK with that too?

Could we stop the API inflation and code churn, please.

You have little idea of the hassle this means for people like us doing
backports and code maintenance, preventing us from doing useful work,
like fixing real bugs and issues.

You know, even something very simple as the 'extern' removal in include
files had consumed days of work for us because of merge conflicts, and
reviewer time.

( commit 5c9f30236f53f3fbee170e2452dfa0e5dce4727b for example)

We understand the code as is, with regular memcpy() and memset()

These functions are fine. They were fine 20 years ago, nothing changed.

Thanks.
