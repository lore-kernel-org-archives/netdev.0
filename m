From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] 2.6.0-bk6 net/core/dev.c
Date: Wed, 24 Sep 2003 10:17:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064423867.15283.11.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0309241012110.3178-100000@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0309241012110.3178-100000@home.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-09-24 at 10:13, Linus Torvalds wrote:
> Looks sane, but wouldn't it be cleaner to put this ugly special case logic
> with casts etc in an inline function and make the code a bit more readable
> at the same time?

I've got those.

I've done the ((void*)1) conversions to PKT_SHARED_SKBs
and found this missing.  I'll submit those separately.
