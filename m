From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 22:50:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414DF111.3080409@eurodev.net>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <20040919120730.GA6005@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040919120730.GA6005@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>In fact this is the reason why this whole problem is non-existant.
>
>Unless there is a kernel user that sends netlink messages with a timeout
>value other than 0, this patch does not resolve any dead-locks at all
>since there is none to start with.
>

yes, you are totally right, but as I told you before, I'm not focusing=20
my efforts in improving netlink sockets for tools like iproute, for=20
those MSG_DONTWAIT is fairly ok.

>So it looks to me as if this entire patch is simply papering over bugs
>in the user-space application where it either isn't processing the
>messages fast enough or it needs to enlarge its queue size.
> =20
>

I don't agree, enlarging the queue size for applications that send a lot=20
of information in a short period of time is just a workaround.

>Here is a tip, use separate sockets for unicast and multicast messages.
>That way your unicast socket is very unlikely to overrun.
>
>So I'd like to see the whole thing reverted.
> =20
>

Herbert, I don't agree, my patch isn't related to stuff that you've=20
mentioned. It's fairly true that most =E7of application use socket timeou=
t=20
0, but my patch is not for those! :-) well, still disagree?

regards,
Pablo
