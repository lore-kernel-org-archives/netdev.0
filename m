From: kuznet@ms2.inr.ac.ru
Subject: Re: "Loopback" route through two cards?
Date: Tue, 3 Sep 2002 16:54:44 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209031254.QAA02008@sex.inr.ac.ru>
References: <20020903050441.4052F2C414@lists.samba.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, anton@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au (Rusty Russell)
In-Reply-To: <20020903050441.4052F2C414@lists.samba.org> from "Rusty Russell" at Sep 3, 2 03:04:47 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> 	I know this is an FAQ, but I never saw an answer I liked.

And what kind of answers do you like? :-)

> still impossible

It depends on sense which you put to "impossible".

There are two problems with this:

1. You cannot send to local address via any device but loopback.

   The only way to override this is to use explicit SO_BINDTODEVICE
   on sending socket. Hence, it is "impossible" not changing application. 

2. You cannot receive packets with local address from any device
   but loopback.

   This is impossible, but wthis time without not editing kernel,
   removing the check for local addresses in fib_validate_source().

Alexey
