From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 badness continues
Date: Tue, 4 Jan 2005 22:57:43 +0200 (EET)
Message-ID: <Pine.LNX.4.61.0501042254330.30839@netcore.fi>
References: <41DA3A60.8050102@pobox.com> <20050104093335.GB7823@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050104093335.GB7823@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Jan 2005, Lennert Buytenhek wrote:
> On Tue, Jan 04, 2005 at 01:40:32AM -0500, Jeff Garzik wrote:
>
>> Standard FC2 OS with IPv6 6to4 setup as described on
>> http://linux.yyz.us/ipv6-fc2-howto.html
>
> I upgraded my problematic machine to FC3, which somehow broke 6to4, and I
> didn't bother to reenable it again because the local DNS server (dnscache)
> just drops AAAA queries on the floor anyway, leading to lots of timeouts
> when trying to resolve host names, etc.  Ever since 6to4 was turned off
> on that box I stopped seeing these messages.

Surely it doesn't just drop AAAA queries on the floor, but sends an 
error message?

If so, maybe then the problem is that glibc resolver cannot properly 
handle such errors without undue timeouts.

Actually I've just sent a message on libc-alpha@ describing a similar 
timeout issue:

http://sources.redhat.com/ml/libc-alpha/2005-01/msg00007.html

Maybe you could run a little bit of debug on whether the server sends 
errors (which kind) and how the resolver reacts.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
