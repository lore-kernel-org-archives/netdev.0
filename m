From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 11:33:36 -0500 (EST)
Message-ID: <20151119.113336.1788979303067913870.davem@davemloft.net>
References: <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	<20151119.104811.1447518072450380661.davem@davemloft.net>
	<1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, lorenzo@google.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	dtor@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758477AbbKSQdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 11:33:41 -0500
In-Reply-To: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Nov 2015 08:19:24 -0800

> Here is the thing :
> 
> - Android powered phones and devices have a similar code since 2008.
> There is _no_ way they can avoid having this functionality.

Weren't we given similar story about initial wake locks
implementation?  There is no other way, Android does this forever,
we have to have this!

> Every-time I make a change in linux TCP stack, this code breaks, and
> this a  real pain because Android changes need to be carried over to
> vendors.

I'm very glad that you felt the pain enough that you finally had
to reluctantly try and upstream something.  I'm sorry that doing
hackish things locally in the Android kernel tree is so painful :-/

Android folks really do not care about upstream, and it is probably
bottom of their priority.  Their actions consistently support this.

Now I am supposed to urgently care about some of their problems.

What kind of relationship is this?  It sounds quite one sided if you
ask me.

> We have a clear business case here, and I would like we find a solution.

I'm sorry, I thought the plan was to stay on 3.10 kernel in Android
forever, that putting upstream issues as far down the road as
possible.

> Having this code in upstream kernel will save me time and energy to deal
> with real issues and improvements, not with bugs opened by Android
> engineers 9 months after I did changes in upstream kernels.

I think the timeline is more like 2+ years.

Guess what, it's frustrating for me too!

> [2] Taking air time to send keepalive(s) and receive their answers is
> going to make all radio providers shout really loud. They are already
> installing stupid proxies filtering/compressing ACK messages and
> breaking TCP clocking.

I understand.

But you know what, if you just toss some major facility like this onto
the list you have to expect some discussion, disagreement, and
suggestions of alternate schemes.

Some of which you may not like nor consider appropriate at all.

You have been considering this non-stop for whatever time you have
been working on this, everyone else is now considering and thinking
about this for the first time right now.

Therefore you must be understanding and patient.  Just like I've been
patiently waiting for my Nexus 6 to be updated to something newer than
2+ year old kernel technology.

You cannot just say "I signoff on this, it's the only reasonable
scheme, apply it."  That's not how we do things here.

Frankly, that kind of attitude makes me want to apply this series even
less, and encourage attempts to find alternate schemes even more.

Thanks.
