From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Fri, 25 Sep 2015 23:55:11 +0800
Message-ID: <20150925155511.GA9575@gondor.apana.org.au>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com>
 <20150925043653.GA29111@roeck-us.net>
 <20150925045853.GA5286@gondor.apana.org.au>
 <5604DCD2.4090600@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Schlansker <stevenschlansker@gmail.com>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5604DCD2.4090600@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 10:34:10PM -0700, Guenter Roeck wrote:
>
> Any idea what may be needed for 4.1 ?
> I am currently trying https://patchwork.ozlabs.org/patch/473041/,

This patch should not make any difference on 4.1 and later because
4.1 is where I rewrote rhashtable resizing and it should work (or
if it is broken then the latest kernel should be broken too).

> but I have no idea if that will help with the problem we are seeing there.

Having looked at your message agin I don't think the issue I
alluded to is relevant since the symptom there ought to be a
straight kernel lock-up as opposed to just a user-space one because
you will end up with the kernel sending a message to itself.

And the fact that 4.2 works is more indicative as the bug is
present in both 4.1 and 4.2.

I'll try to reproduce this in 4.1 as time permits but no promises.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
