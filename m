From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: crash in __kfree_skb on v3.18-rc5 with CONFIG_DEBUG_PAGEALLOC
Date: Fri, 21 Nov 2014 08:56:35 -0800
Message-ID: <1416588995.8629.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	 <1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416587848.8629.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416588426.24312.6@mail.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:50757 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758554AbaKUQ4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 11:56:39 -0500
Received: by mail-ie0-f171.google.com with SMTP id rl12so5246384iec.2
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 08:56:38 -0800 (PST)
In-Reply-To: <1416588426.24312.6@mail.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-21 at 11:47 -0500, Chris Mason wrote:

> Once my current run is done, I can revert this and try a loop.  But I 
> don't see how this commit causes a use-after-free on the skb itself?

Well, it is so obvious, you really want to make me miserable ;)

I am testing the revert and send it asap.
