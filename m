From: Daolong Wang <ahlongxp@gmail.com>
Subject: Re: [PATCH] NET: fix wrong English expression in comments
Date: Tue, 13 Jan 2009 14:16:02 +0800
Message-ID: <dc84318c0901122216s77bae26eo2dd36c4a0ee35177@mail.gmail.com>
References: <496a3c51.09876e0a.03fe.7e80@mx.google.com>
	 <496A9753.80802@cn.fujitsu.com>
	 <1231724358.2674.13.camel@hashbaz.i.decadent.org.uk>
	 <20090112.215320.197154233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, lizf@cn.fujitsu.com,
	qhfeng.kernel@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:61996 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759908AbZAMGQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 01:16:04 -0500
In-Reply-To: <20090112.215320.197154233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch will make sense for some people. I was puzzled about the
double-negative for quite a while.

On Tue, Jan 13, 2009 at 1:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 12 Jan 2009 01:39:18 +0000
>
>> On Mon, 2009-01-12 at 09:05 +0800, Li Zefan wrote:
>> > > @@ -103,7 +103,7 @@ struct inet_bind_bucket;
>> > >  struct inet_timewait_sock {
>> > >   /*
>> > >    * Now struct sock also uses sock_common, so please just
>> > > -  * don't add nothing before this first member (__tw_common) --acme
>> > > +  * don't add anything before this first member (__tw_common) --acme
>> >
>> > They are the same meaning...
>>
>> A double-negative can be an informal way of reinforcing a negative, but
>> can sometimes mean the positive.  So this change would remove a minor
>> ambiguity.  However I think it should be clear that it is not compulsory
>> to add new members to the structure. ;-)
>
> After all of this discussion, I think I'm going to keep this comment
> as-is. :-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
