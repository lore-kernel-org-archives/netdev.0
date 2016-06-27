From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Mon, 27 Jun 2016 23:22:05 +0200
Message-ID: <1467062525.6850.173.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
	 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37018 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbcF0VWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 17:22:08 -0400
Received: by mail-wm0-f47.google.com with SMTP id a66so557581wme.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 14:22:07 -0700 (PDT)
In-Reply-To: <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 10:58 -0700, Andy Lutomirski wrote:

> Seems reasonable.
> 
> I wonder if it's worth switching from ahash to shash, though.  It
> would probably be simpler and faster.

Well, I have no opinion on this, I will let a crypto guy doing this
change if he cares ;)

Thanks.
