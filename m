From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Wed, 14 Aug 2002 21:25:39 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208141725.VAA24463@sex.inr.ac.ru>
References: <20020814045755.GB32315@anakin.wychk.org>
Mime-Version: 1.0
Cc: davem@redhat.com (Dave Miller), netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020814045755.GB32315@anakin.wychk.org> from "Geoffrey Lee" at Aug 14, 2 02:57:55 pm
List-Id: netdev.vger.kernel.org

Hello!

> So, in the near future, we can expect Linux to not return 0 for
> non-blocking connects (i.e. the change you mentioned)?

I wanted, but I changed my opinion about this. It is pretty strange to mimic
behavior of solaris/tru64 and Co, which is really stinking.

So, despite of our current behavior is not perfect and even not
quite self-consistent, it is the best one. Well, and it does not
contradict to sus/posix.

So, connect() remains restartable, and it will return 0 on success
instead of EISCONN crap.

Alexey
