From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: use set_curren_state to ensure mb
Date: Wed, 06 Jun 2012 10:48:19 -0700 (PDT)
Message-ID: <20120606.104819.205494704315981439.davem@davemloft.net>
References: <CAA7+ByX7Kp+Zh3ZQ2D6rSuhu6WCeqL-1MgDi9gy-0hHizVXncg@mail.gmail.com>
	<1338894329.2760.2318.camel@edumazet-glaptop>
	<CAA7+ByUH8LsSrbetHngEZmaHkvK5aUO5v7-F=+wbveo6q68f-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, arnd@arndb.de,
	zhiguo.hong@nsn.com, vikifang@juniper.net
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757717Ab2FFRsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:48:20 -0400
In-Reply-To: <CAA7+ByUH8LsSrbetHngEZmaHkvK5aUO5v7-F=+wbveo6q68f-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong zhi guo <honkiko@gmail.com>
Date: Tue, 5 Jun 2012 20:05:34 +0800

> On Tue, Jun 5, 2012 at 7:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Why not using the more standard :
>>
>> prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>>
>> and
>>
>> finish_wait(sk_sleep(sk), &wait);
>>
> 
> Thanks for your comments.  The difference is that prepare_to_wait
> inside loop introduces extra "list_empty" judgement than original
> patch. But personally I prefer the newer version too:
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

Please don't submit patches like this:

1) When submitting new versions of a patch, make a fresh
   new mailing list posting with just the patch and it's
   commit message.

   Do not post new versions by replying to other conversations.

2) Your email client has severely corrupted the patch, breaking
   up long lines etc.  Please read Documentation/email-clients.txt
   to learn how to fix this.
